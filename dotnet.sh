# Get input from user
echo "Create a .NET project."
read -p "Project name: " name
read -p "Author name: " author
read -p "Service port: " port
read -p "Deploy branch: " branch
lowerstr=$(echo $name | tr '[:upper:]' '[:lower:]')
echo "Creating .NET project: $name ($lowerstr)"
now=$(date +'%-m/%-d/%Y')

# Create .NET WebApi in the user-given directory
mkdir ~/dev/Backend
cd ~/dev/Backend
dotnet new webapi -o $name
cd $name

# Add .NET packages
dotnet add package Microsoft.EntityFrameworkCore.InMemory
dotnet add package supabase-csharp --version 0.3.3

# Remove boilerplate code
rm -R Controllers/*
rm WeatherForecast.cs

# Generate namespace directories
mkdir Controllers
mkdir Models
mkdir Services
mkdir Utilities
mkdir .github
mkdir .github/workflows

# Generate template and static files
touch Controllers/Controller.cs
touch Models/Model.cs
touch Services/Service.cs
touch Utilities/Logger.cs
touch .github/workflows/deploy.yml

# Write template code
echo "/*
* Controller.cs
* Author: $author
* Created on: $now
*/

using Microsoft.AspNetCore.Mvc;
using $name.Models;

namespace $name.Controllers;

[ApiController]
[Route(\"[controller]\")]
public class Controller : ControllerBase
{
  public Controller()
  {
  }

  [HttpGet(\"get\")]
  public void Get()
  {
  }

  [HttpPost(\"set\")]
  public void Set([FromBody] Model model)
  {
  }
}" > Controllers/Controller.cs
echo "/*
* Model.cs
* Author: $author
* Created on: $now
*/

using Supabase;
using Postgrest.Attributes;

namespace $name.Models;

[Table(\"database-table\")]
public class Model : SupabaseModel
{
  [PrimaryKey(\"id\", false)]
  public int Id { get; set; } = -1;
  [Column(\"database-column\")]
  public string ColumnValue { get; set; } = \"\";
}" > Models/Model.cs
echo "/*
* Service.cs
* Author: $author
* Created on: $now
*/

using Supabase;

namespace $name.Services;

public class Service
{
  public static Service Instance = new Service();
  private static bool hasInstance = false;
  private Service()
  {
    if (hasInstance) 
    {
      System.Environment.Exit(-1);
      return;
    }
    hasInstance = true;
  }
}" > Services/Service.cs
echo "/*
* Logger.cs
* Author: $author
* Created on: $now
*/

namespace $name.Util;

public class Logger
{
  public static void Info(string location, string msg)
  {
    var now = DateTime.Now.ToString(\"M/d/yyyy h:mm:ss tt\");
    var line = $\"[{now}] [INFO \" + location + \"]: \" + msg;
    Console.WriteLine(line);
  }

  public static void Error(string location, string msg)
  {
    var now = DateTime.Now.ToString(\"M/d/yyyy h:mm:ss tt\");
    var line = $\"[{now}] [ERROR \" + location + \"]: \" + msg;
    Console.WriteLine(line);
  }
}" > Utilities/Logger.cs
echo "/*
* DatabaseService.cs
* Author: $author
* Created on: $now
*/

using Supabase;
using $name.Util;

namespace $name.Services;

public class DatabaseService
{
  public static DatabaseService Instance = new DatabaseService();
  private static bool hasInstance = false;
  private static bool setupDone = false;
  private string? url;
  private string? key;
  private Client? client;

  public DatabaseService()
  {
    if (hasInstance) return;
    hasInstance = true;
  }

  public async void DatabaseSetup()
  {
    if (setupDone) return;
    setupDone = true;

    Logger.Info(\"$name.Services.DatabaseService\", \"Connecting to database...\");

    url = \"<supabase-url>\";
    key = \"<supabase-key>\";

    await Client.InitializeAsync(url, key);
    client = Client.Instance;
  }

  public async Task<T[]> FetchTable<T>() where T : SupabaseModel, new()
  {
    SupabaseTable<T> table = client!.From<T>();
    var data = await table.Select(\"*\").Get();
    return data.Models.ToArray();
  }

  public async Task<T[]> FetchTable<T>(string column, string filter) where T : SupabaseModel, new()
  {
    SupabaseTable<T> table = client!.From<T>();
    var data = await table.Filter(column, Postgrest.Constants.Operator.Equals, filter).Get();
    return data.Models.ToArray();
  }

  public async void AddRow<T>(T rowData) where T : SupabaseModel, new()
  {
    SupabaseTable<T> table = client!.From<T>();
    await table.Insert(rowData);
  }
}" > Services/DatabaseService.cs
echo "using $name.Util;
using $name.Services;

var builder = WebApplication.CreateBuilder(args);
var Cors = \"\";

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddCors(options => {
  options.AddPolicy(name: Cors, _builder => {
    _builder.AllowAnyHeader().AllowAnyMethod().AllowAnyOrigin();
  });
});

var app = builder.Build();

DatabaseService.Instance.DatabaseSetup();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();
app.MapControllers();

Logger.Info(\"Program\", \"Application started\");
app.Run(\"http://0.0.0.0:$port\");
Logger.Info(\"Program\", \"Application ended\");
" > Program.cs
echo "version: '3'
services:
  $lowerstr:
    build: .
    container_name: $lowerstr
    restart: on-failure
    ports: 
    - 0.0.0.0:$port:$port
" > docker-compose.yml
echo "FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /App
COPY . /App/
ENTRYPOINT [\"dotnet\", \"$name.dll\"]
" > Dockerfile
echo "name: Deploy Backend
on:
  push:
    branches:
    - $branch
jobs:
  build_and_deploy:
    name: Build and Deploy
    runs-on: ubuntu-latest
    env:
      PROJECT_ID: '$lowerstr'
    steps:
    - name: Checkout repository
      uses: actions/checkout@v2
    - name: Install requirements
      run: wget -O - https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh | bash && sudo apt-get install -y rsync
    - name: Build project
      run: /home/runner/.dotnet/dotnet build && /home/runner/.dotnet/dotnet publish -c Release && chmod -R 777 /home/runner/work/*
    - name: Setup Docker requirements
      run: cp Dockerfile bin/Release/net6.0/publish/Dockerfile && cp docker-compose.yml bin/Release/net6.0/publish/docker-compose.yml
    - name: Deploy to IONOS
      uses: easingthemes/ssh-deploy@main
      env:
        SSH_PRIVATE_KEY: \${{ secrets.SSH_PRIVATE_KEY }}
        REMOTE_HOST: \${{ secrets.REMOTE_HOST }}
        REMOTE_USER: \${{ secrets.REMOTE_USER }}
        TARGET: '/root/services/\${{ env.PROJECT_ID }}/'
        SOURCE: 'bin/Release/net6.0/publish/'
    - name: Rebuild Docker containers
      uses: appleboy/ssh-action@master
      with:
        host: \${{ secrets.REMOTE_HOST }}
        username: \${{ secrets.REMOTE_USER }}
        password: \${{ secrets.REMOTE_PASSWORD }}
        port: \${{ secrets.REMOTE_PORT }}
        script: 'mkdir -p /root/services/\${{ env.PROJECT_ID }} && cd /root/services/\${{ env.PROJECT_ID }}/ && docker-compose stop && docker-compose build && docker-compose up -d'
" > .github/workflows/deploy.yml
echo "name: Restart Backend
on:
  workflow_dispatch
jobs:
  restart:
    name: Restart process
    runs-on: ubuntu-latest
    env:
      PROJECT_ID: '$lowerstr'
    steps:
    - name: Rebuild Docker containers
      uses: appleboy/ssh-action@master
      with:
        host: \${{ secrets.REMOTE_HOST }}
        username: \${{ secrets.REMOTE_USER }}
        password: \${{ secrets.REMOTE_PASSWORD }}
        port: \${{ secrets.REMOTE_PORT }}
        script: 'mkdir -p /root/services/\${{ env.PROJECT_ID }} && cd /root/services/\${{ env.PROJECT_ID }}/ && docker-compose stop && docker-compose build && docker-compose up -d'
" > .github/workflows/restart.yml
echo "name: Register Proxy Backend
on:
  workflow_dispatch
jobs:
  restart:
    name: Changing proxy config
    runs-on: ubuntu-latest
    env:
      PROJECT_ID: '$lowerstr'
    steps:
    - name: Changing proxy config
      uses: appleboy/ssh-action@master
      with:
        host: \${{ secrets.REMOTE_HOST }}
        username: \${{ secrets.REMOTE_USER }}
        password: \${{ secrets.REMOTE_PASSWORD }}
        port: \${{ secrets.REMOTE_PORT }}
        script: 'java -jar /root/haproxy-service/haproxy-service.jar create \${{ env.PROJECT_ID }} $port'
" > .github/workflows/register-proxy.yml
echo "name: Unregister Proxy Backend
on:
  workflow_dispatch
jobs:
  restart:
    name: Changing proxy config
    runs-on: ubuntu-latest
    env:
      PROJECT_ID: '$lowerstr'
    steps:
    - name: Changing proxy config
      uses: appleboy/ssh-action@master
      with:
        host: \${{ secrets.REMOTE_HOST }}
        username: \${{ secrets.REMOTE_USER }}
        password: \${{ secrets.REMOTE_PASSWORD }}
        port: \${{ secrets.REMOTE_PORT }}
        script: 'java -jar /root/haproxy-service/haproxy-service.jar remove \${{ env.PROJECT_ID }}'
" > .github/workflows/unregister-proxy.yml

# Print info messages
echo "----- [ INFORMATION ] -----"
echo "To deploy the application to IONOS with the GitHub Action, add SSH_PRIVATE_KEY, REMOTE_USER, REMOTE_HOST, REMOTE_PASSWORD and REMOTE_PORT to the repository secrets on GitHub."

# Open in VSCode
code ../$name
