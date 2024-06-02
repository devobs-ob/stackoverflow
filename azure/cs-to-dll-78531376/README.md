# Solution to StackOverflow Question

## Problem Description
When building an ASP.NET project in Azure DevOps, the .cs files are not converted to .dll files. We need to ensure that these files are compiled into a .dll named App_Code.dll and stored in the Bin folder.

## Solution
The solution involves configuring the Azure DevOps build pipeline to correctly compile the .cs files into a .dll file.

## Files
- `azure-pipelines.yml`: Defines the Azure DevOps pipeline configuration.
- `MyAspNetApp.csproj`: Project file with custom MSBuild target.
- `App_Code/SampleClass.cs`: Sample C# class to be compiled.

## Usage
1. Set up the pipeline in Azure DevOps using the `azure-pipelines.yml` file.
2. Ensure the .csproj file includes the necessary configuration.
3. Run the pipeline and verify the output in the Bin folder.
