# Get input from user
echo "Create a .NET project."
read -p "Project name: " name
read -p "Author name: " author
echo "Creating .NET project: $name"
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

# Generate template and static files
touch Controllers/Controller.cs
touch Models/Model.cs
touch Services/Service.cs
touch Utilities/Logger.cs

#Write template code
echo "
/*
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
echo "
/*
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
echo "
/*
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
}
" > Services/Service.cs
echo "
/*
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
}
" > Utilities/Logger.cs
echo "
/*
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
}
" > Services/DatabaseService.cs

echo "Don't forget to run DatabaseService.Instance.SetupDatabase(); before executing app.Run();"

# Open in VSCode
code ../$name
