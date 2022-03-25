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

# Open in VSCode
code ../$name
