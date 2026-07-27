# Mod Loader - VoxBrasil (PT-BR)

> **Créditos ao projeto original:** Este repositório é baseado no projeto **Mod Loader**, desenvolvido por seus autores originais. Eu apenas fiz um fork deste projeto para dar continuidade ao seu desenvolvimento, traduzindo para português (PT-BR), corrigindo bugs, adicionando melhorias e mantendo-o atualizado para a comunidade brasileira de GTA San Andreas / SA-MP.

## Sobre

O **Mod Loader** é um plugin para **Grand Theft Auto III**, **Vice City** e **San Andreas** que adiciona uma forma simples, prática e amigável de instalar e desinstalar modificações no jogo, como se ele tivesse suporte oficial para mods.

Nenhuma alteração é feita nos arquivos originais do jogo. Todos os mods são carregados dinamicamente durante a execução do jogo, mantendo sua instalação original intacta.

### Principais vantagens

- ✅ Instalação extremamente simples.
- ✅ Não modifica os arquivos originais do GTA.
- ✅ Organização dos mods em pastas.
- ✅ Ativar ou remover mods facilmente.
- ✅ Suporte para Hot Reload (troca de mods enquanto o jogo está aberto, quando suportado).

## Como utilizar

Basta colocar seus arquivos de mod dentro da pasta:

```
modloader/
```

Para remover um mod, basta apagar sua pasta ou arquivos da pasta `modloader`.

Simples assim.

---

## Projeto VoxBrasil

Este repositório é uma continuação do projeto original.

O objetivo é:

- 🇧🇷 Traduzir todo o projeto para Português Brasileiro;
- 🔧 Corrigir bugs;
- 🚀 Atualizar o código para versões mais recentes do Visual Studio;
- 📦 Melhorar a compatibilidade com GTA SA, SA-MP e Open.MP;
- 💻 Modernizar o sistema de compilação;
- 🛠️ Adicionar novas funcionalidades futuramente.

Este projeto **não reivindica autoria do Mod Loader original**. Todos os créditos pelo desenvolvimento inicial pertencem aos seus criadores.

---

# Compilação

## Requisitos

- Premake 5
- Visual Studio 2017 ou superior (recomendado Visual Studio 2022)
- Windows XP Platform Toolset (caso necessário)

## Gerando os arquivos do projeto

Execute na pasta raiz:

```bash
premake5 vs2022
```

---

## Instalando diretamente no GTA

Você pode instalar automaticamente os arquivos compilados para a pasta do jogo utilizando:

```bash
premake5 install "C:/Program Files (x86)/Rockstar Games/GTA San Andreas"
```

---

## Instalação automática ao compilar

Também é possível configurar o Premake para copiar automaticamente os arquivos para a pasta do jogo sempre que o projeto for compilado:

```bash
premake5 vs2022 "--idir=C:/Program Files (x86)/Rockstar Games/GTA San Andreas"
```

---

## Créditos

**Projeto Original**

Mod Loader

Autores originais e colaboradores da comunidade GTA.

**Fork Brasileiro**

VoxBrasil

Responsável por:

- Tradução para Português (PT-BR)
- Atualizações
- Correções
- Melhorias
- Manutenção do projeto

---

Este projeto é um fork do Mod Loader original e existe com o objetivo de manter o projeto vivo, atualizado e acessível para a comunidade brasileira.
