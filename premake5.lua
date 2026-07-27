
--[[
    Script de Compilação do Mod Loader
    Utilize:
        premake5 --help
    para visualizar a ajuda.

    Tradução PT-BR: VoxBrasil
]]



--[[
    Opções e Ações
--]]

newoption {
    trigger     = "outdir",
    value       = "path",
    description = "Diretório de saída para os arquivos de compilação."
}
if not _OPTIONS["outdir"] then
    _OPTIONS["outdir"] = "build"
end

newoption {
    trigger     = "idir",
    value       = "path",
    description = "Diretório de instalação após a compilação."
}

newoption {
    trigger     = "final-release",
    description = "Gera uma versão pública (define MODLOADER_FINAL_RELEASE para toda a solução)."
}

newaction {
    trigger     = "clean",
    description = "Remove os arquivos de compilação e binários do projeto (bin/, build_temp/ e release/).",
    execute     = function()
        os.rmdir("bin")
        os.rmdir("build_temp")
        os.rmdir("release")
    end
}

newaction {
    trigger     = "install",
    description = "Instala uma versão previamente compilada do Mod Loader no diretório informado como segundo argumento.",
    execute     = function()
        local dest = _ARGS[1]
        if dest == nil then
            print("O segundo argumento (diretório de instalação) não foi informado.\nAbortando.")
        else
            dest = makeabsolute(dest)
            print("Instalando em \"" .. dest .. "\"...")
            for i, cmd in ipairs(installcommands(dest)) do
                os.execute(cmd)
            end
        end
    end
}




--[[
    Funções de Instalação
--]]

install_files = {}
cmd_copyfile = os.ishost("windows") and { "xcopy", "/f /y /i" }    or { "cp", "-v" }
cmd_copydir  = os.ishost("windows") and { "xcopy", "/e /f /y /i" } or { "cp", "-vr" }

-- Obtém o comando de instalação para um arquivo
function installcommand(file, destdir)

    if file.isdir == nil then
        file.isdir = not os.isfile(file.source)
    end

    local cmd = string.format(path.translate([[%s "%s/%s" "%s/%s%s" %s]]),
                    file.isdir and cmd_copydir[1] or cmd_copyfile[1],
                    path.translate(_MAIN_SCRIPT_DIR), path.translate(file.source),
                    path.translate(destdir), path.translate(file.destination), path.translate(file.isdir and "" or "/*"),
                    file.isdir and cmd_copydir[2] or cmd_copyfile[2])

    return cmd
end

-- Obtém todos os comandos de instalação adicionados via addinstall()
function installcommands(destdir)
    local cmds = {}

    for i, file in ipairs(install_files) do
        table.insert(cmds, installcommand(file, destdir))
    end

    return cmds
end

-- Adiciona um arquivo à lista de instalação
function addinstall(file)
    table.insert(install_files, file)
    if _OPTIONS["idir"] then
        postbuildcommands { installcommand(file, makeabsolute(_OPTIONS["idir"])) }
    end
end

function makeabsolute(pathx)
    return path.isabsolute(pathx) and pathx or (_MAIN_SCRIPT_DIR .. '/' .. pathx)
end



--[[
    Utilidades da Solução
--]]

asm_extension = (_ACTION == "gmake" and "s" or "cc")    -- Não utilize .c no MSVC (quebra o PCH)

function binarydir(dir)
    targetdir("bin/" .. dir)
    implibdir("bin/" .. dir)
end

function setupfiles(dir)
    files {
        dir .. "/**.cpp",
        dir .. "/**.h",
        dir .. "/**.hpp",
        dir .. "/**." .. asm_extension
    }
end

function pchsetup(pchdir)
    pchheader "stdinc.hpp"
    pchsource "src/shared/stdinc/stdinc.cpp"
    files { "src/shared/stdinc/stdinc.cpp" }
    includedirs { pchdir }
end

function addplugin(name)

    local directory = ("src/plugins/gta3/" .. name .. "/")
    local has_pch   = os.isfile(directory .. "/stdinc.hpp")
    local pch_dir   = has_pch and directory or "src/shared/stdinc/gta3/"

    project(name)
        language "C++"
        kind "SharedLib"

        binarydir "plugins/gta3"

        addinstall({
            isdir = false,
            source = "bin/plugins/gta3/" .. name .. ".dll",
            destination = "modloader/.data/plugins/gta3"
        })

        includedirs {
            "src/shared/game/gta3"
        }

        links { "addr" }
        dependson { "modloader" }
        setupfiles(directory)
        pchsetup(pch_dir)

end

function dummyproject()

    kind "Makefile"
    language "C++"
    flags { "NoPCH" }

    -- Arquivo fictício utilizado para contornar um problema do Premake no GMake
    filter "action:gmake*"
        kind "StaticLib"
        files { "src/shared/dummy.cpp" }

    filter {}
end



--[[
    Configuração da Solução
--]]

solution "modloader"

    startproject "build_gta3"

    configurations { "Release", "Debug" }

    location(_OPTIONS["outdir"])

    targetprefix ""
    targetdir "bin"
    implibdir "bin"

    staticruntime "On"
    symbols "On" -- Sempre gerar símbolos para auxiliar na geração de logs.

    flags {
        "NoImportLib",
        "NoBufferSecurityCheck"
    }

    defines {
        "INJECTOR_GVM_HAS_TRANSLATOR",
        'INJECTOR_GVM_PLUGIN_NAME="\\"Mod Loader Plugin\\""'
    }

    defines {
        "NOMINMAX",
        "_CRT_SECURE_NO_WARNINGS",
        "_SCL_SECURE_NO_WARNINGS"
    }

    if _OPTIONS["final-release"] then
        defines { "MODLOADER_FINAL_RELEASE" }
    end

    includedirs {
        "include",
        "deps/cereal/include",
        "deps/injector/include",
        "deps/boost",
        "deps/tinympl",
        "deps/utf8-cpp/source",
        "src/shared",
    }

    filter "configurations:Debug*"
        symbols "On"

    filter "configurations:Release*"
        defines { "NDEBUG" }
        optimize "Speed"

    filter "action:gmake*"
        buildoptions { "-std=gnu++14", "-Wno-deprecated" }

    -- Visual Studio 2017+ (v141_xp)
    filter "action:vs*"
        toolset "v141_xp"
        buildoptions { "/arch:IA32" }
        buildoptions { "/Zm250", "/bigobj" }
        buildoptions { "/Zc:threadSafeInit-" }

    filter {}
