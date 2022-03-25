# Get input from user
echo "Create a .NET project."
read -p "Name: " name
echo "Creating .NET project: $name"

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

# Open in VSCode
code ../$name
