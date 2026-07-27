--[[
    release.lua
        Prepara uma versão pública do Mod Loader.
        Utilize:
            premake5 --file=release.lua --help
        para visualizar todas as opções disponíveis.

    Tradução PT-BR: VoxBrasil
--]]

newaction {
    trigger     = "prepare",
    description = "Compila automaticamente a versão Release e prepara os arquivos para distribuição pública.",
    execute     = function() main() end
}

newoption {
    trigger     = "toolset",
    value       = "ferramentas",
    description = "Conjunto de ferramentas utilizado para compilar a versão Release (vs20xx ou gcc).",
}

newoption {
    trigger     = "final-release",
    description = "Gera uma compilação para distribuição pública."
}

toolset     = _OPTIONS["toolset"]
final_flag  = _OPTIONS["final-release"] and " --final-release" or ""
action      = (toolset == "gcc" and "gmake" or toolset)
compiler    = (toolset == "gcc" and "gcc" or "cl")
build       = (toolset == "gcc" and "make" or "msbuild")

function main()

    if not toolset then
        print("Nenhum conjunto de ferramentas (toolset) foi informado.\nAbortando.")
        exit()
    end

    if toolset ~= "gcc" and not toolset:match("^vs") then
        print("Toolset '" .. toolset .. "' não suportado. Utilize uma ação do Visual Studio (vs20xx) ou gcc.\nAbortando.")
        exit()
    end

    require_tools()

    local install = function()
        print("Criando estrutura da pasta Release...")

        execute("premake5 install ./release/binaries/")

        os.copyfile("./release/binaries/modloader/.data/Readme.md", "./release/binaries/Readme.txt")
        os.copyfile("./release/binaries/modloader/.data/Leia-me.md", "./release/binaries/Leia-me.txt")

        os.mkdir("./release/binaries/modloader/.profiles")
    end

    print("Limpando arquivos da compilação...")
    execute("premake5 clean")

    print("Gerando arquivos do projeto...")

    if toolset == "gcc" then
        execute(string.format(
            "premake5 %s --cc=%s --outdir=build_temp%s",
            action,
            compiler,
            final_flag
        ))
    else
        execute(string.format(
            "premake5 %s --outdir=build_temp%s",
            action,
            final_flag
        ))
    end

    print("Compilando projeto...")

    if build == "msbuild" then

        -- Também é possível utilizar:
        -- set CL=/MP
        -- no release.bat

        execute("msbuild build_temp/modloader.sln /p:configuration=Release /p:platform=Win32 /m")

        install()

        pdbpackage()

    elseif compiler == "gcc" then

        local cwd = os.getcwd()

        os.chdir("build_temp")

        execute("mingw32-make CC=gcc")

        os.chdir(cwd)

        -- Remove símbolos de depuração (sempre)
        gccstrip()

        -- A remoção de símbolos não interfere na exportação deles.
        -- Para manter símbolos exportados utilize:
        -- --export-all-symbols

        install()

    else

        print("Erro interno.")
        exit()

    end

    os.rmdir("build_temp")
end

function pdbpackage()

    print("Empacotando símbolos de depuração (release/symbols)...")

    os.mkdir("release/symbols")
    os.mkdir("release/symbols/modloader/.data/plugins/gta3")

    execute('pdbcopy "bin/modloader.pdb" "release/symbols/modloader.pdb" -p')

    for i, file in ipairs(os.matchfiles("bin/plugins/gta3/*.pdb")) do

        local name = path.getname(file)

        execute(string.format(
            'pdbcopy "bin/plugins/gta3/%s" "release/symbols/modloader/.data/plugins/gta3/%s" -p',
            name,
            name
        ))
    end
end

function gccstrip()

    print("Removendo símbolos das bibliotecas GCC...")

    local cwd = os.getcwd()

    os.chdir("bin")

    for i, file in ipairs(os.matchfiles("*.asi")) do
        execute(string.format([[strip "%s"]], file))
    end

    for i, file in ipairs(os.matchfiles("**.dll")) do
        execute(string.format([[strip "%s"]], file))
    end

    os.chdir(cwd)

end

function require_tools()

    require_on_path(
        "premake5",
        "Instale o Premake 5 e adicione-o à variável PATH do sistema."
    )

    if build == "msbuild" then

        require_on_path(
            "msbuild",
            "Instale o Visual Studio com o MSBuild e execute este script pelo 'x86 Native Tools Command Prompt'."
        )

        require_on_path(
            "pdbcopy",
            "Instale o componente 'Debugging Tools for Windows' do Windows SDK e adicione '%ProgramFiles(x86)%\\Windows Kits\\10\\Debuggers\\x86' ao PATH."
        )

    elseif compiler == "gcc" then

        require_on_path(
            "mingw32-make",
            "Instale o MinGW e adicione o mingw32-make à variável PATH."
        )

    end
end

function require_on_path(name, hint)

    if not os.ishost("windows") then
        return
    end

    local found = os.outputof("where " .. name .. " 2>nul")

    if not found or found == "" then

        print("Erro: '" .. name .. "' não foi encontrado na variável PATH.")

        if hint then
            print(hint)
        end

        exit()

    end
end

function execute(command)

    local result = os.execute(command)

    if result == 0 or result == true then
        return
    end

    print("Falha ao executar o comando:\n" .. command .. "\n\nAbortando.")

    exit()

end

function exit()
    os.exit()
end
