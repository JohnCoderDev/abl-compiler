# ABL Compiler Builder
This is a repo with classes that permity easily specify
the build of a project in abl.

## Quick Start

```progress
using classes.ablc.* from propath.

define variable compilerObject as ABLCompiler.

compilerObject = new ABLCompiler().

compilerObject
	:addSourceDirectory("C:\temp")
	// ... many other source directories
	:addTargetDirectory("C:\temp\results")
	// ... many other target directories
	:compile().
```

## Using the `ABLCompilerService` class

In simple words, it runs periodically the `compile` method
with an specified compiler. In other words, use as example
the compiler object defined above:

```progress
// ...

define variable compilerService as ABLCompilerService.
compilerService = new ABLCompilerService(compilerObject).

compilerService
	:setInterval(5) // calls compilerObject:compile() every 5 seconds
	:startService().
```

## Using the CLI 

You can install the cli in your computer running the script [install-ablc](./src/cli/install-ablc.bat).
After that, in the cmd or powershell the command `ablc` must be available in your computer.
Check that typing the following command to display the help:

```console
> ablc -h
```

