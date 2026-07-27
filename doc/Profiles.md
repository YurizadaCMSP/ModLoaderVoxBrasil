# Perfis do Mod Loader
========================

O **Mod Loader** possui um recurso muito útil chamado **Perfis (Profiles)**, que permite controlar quais modificações serão carregadas em diferentes situações.

Com os perfis, é possível:

- Carregar apenas determinados mods;
- Ignorar mods específicos;
- Ignorar arquivos específicos;
- Definir prioridades entre mods;
- Criar configurações diferentes para GTA San Andreas, SA-MP, Open.MP e outros executáveis.

---

## Como utilizar um perfil

Você pode selecionar um perfil de três maneiras:

- Alterando o perfil atual na configuração principal do **modloader.ini**;
- Iniciando o jogo com o parâmetro de linha de comando:

```text
-modprof NomeDoPerfil
```

- Utilizando a opção **UseIfModule**, que ativa automaticamente um perfil quando um determinado módulo (DLL ou executável) estiver carregado.

---

## Criando um perfil

Para criar ou editar um perfil, abra o arquivo:

```text
modloader.ini
```

ou crie um novo arquivo `.ini` dentro da pasta:

```text
.profiles/
```

O nome do arquivo pode ser qualquer um.

---

## Estrutura de um perfil

Para que o Mod Loader reconheça um perfil, o arquivo deve conter pelo menos uma seção com este formato:

```ini
[Profiles.NomeDoPerfil.Config]
```

Onde:

- **Profiles** → identifica o sistema de perfis;
- **NomeDoPerfil** → nome do perfil;
- **Config** → seção de configuração.

### Exemplo

```ini
[Profiles.SAMP.Config]
```

Este exemplo cria um perfil chamado **SAMP**.

> **Observação:** Os nomes dos perfis **não diferenciam letras maiúsculas e minúsculas**.

---

# [Profiles.NomeDoPerfil.Config]

## Parents = NomeDoPerfil|$Current|$None

Define um ou mais perfis "pais", dos quais este perfil herdará todas as configurações.

Isso inclui:

- prioridades;
- arquivos ignorados;
- mods ignorados;
- demais configurações.

Exemplo:

```ini
Parents = Padrão
```

ou

```ini
Parents = Padrão|SAMP
```

### Valores especiais

### `$Current`

Herda as configurações do perfil atualmente selecionado no **modloader.ini**.

Útil para perfis condicionais.

### `$None`

Não herda nenhuma configuração.

Se `$None` estiver presente na lista de pais, nenhuma herança será realizada.

Valor padrão:

```ini
$None
```

---

## IgnoreAllMods = true|false

Ignora todos os mods existentes na pasta **modloader**.

Na prática, é como desativar completamente o Mod Loader.

Valor padrão:

```ini
false
```

> **Observação:** A opção `IgnoreAllFiles` possui exatamente o mesmo efeito.

---

## ExcludeAllMods = true|false

Ignora todos os mods da pasta **modloader**, exceto aqueles listados em:

```ini
[Profiles.NomeDoPerfil.IncludeMods]
```

Valor padrão:

```ini
false
```

---

## UseIfModule = NomeDoMódulo

Força o uso deste perfil quando determinado executável ou DLL estiver carregado.

Alterações nesta opção só terão efeito após reiniciar o jogo.

É muito útil para criar perfis automáticos para:

- SA-MP
- Open.MP
- MTA
- Outros mods

### Exemplo

```ini
UseIfModule = SAMP
```

Quando o **SAMP.dll** estiver carregado, este perfil será utilizado automaticamente.

> **Importante:** O perfil é carregado como uma cópia temporária (anônima). Alterações feitas durante o jogo não serão salvas neste perfil.

---

# [Profiles.NomeDoPerfil.IgnoreMods]

Todos os mods listados nesta seção serão ignorados durante o carregamento.

Suporta caracteres curinga (*wildcards*).

Exemplo:

```ini
HUD Antiga*
```

---

# [Profiles.NomeDoPerfil.IncludeMods]

Quando `ExcludeAllMods = true`, somente os mods listados nesta seção serão carregados.

Também suporta *wildcards*.

Exemplo:

```ini
Meu HUD
Meu ENB
```

---

# [Profiles.NomeDoPerfil.ExclusiveMods]

Os mods listados aqui serão carregados **exclusivamente** por este perfil.

Qualquer outro perfil irá ignorá-los automaticamente.

Se outro perfil também definir um mod exclusivo, ambos continuarão funcionando normalmente dentro de seus respectivos perfis.

Suporta *wildcards*.

---

# [Profiles.NomeDoPerfil.IgnoreFiles]

Todos os arquivos listados aqui serão ignorados pelo Mod Loader durante a varredura.

É possível utilizar *wildcards* inclusive em subpastas.

### Exemplo

```ini
to_ignore/*.dff
```

Isso fará com que todos os arquivos `.dff` da pasta:

```text
modloader/Meu Mod/to_ignore/
```

sejam ignorados.

> **Importante:** A pasta deve estar dentro do diretório do mod.

---

# [Profiles.NomeDoPerfil.Priority]

Define a prioridade dos mods.

Quando dois mods modificam o mesmo arquivo, o Mod Loader utilizará aquele que possuir maior prioridade.

Formato:

```ini
NomeDoMod = Prioridade
```

A prioridade varia de:

```text
0 até 100
```

### Exemplo

```ini
SkyGFX = 90
Project2DFX = 80
Meu HUD = 100
```

Neste exemplo, caso dois mods alterem o mesmo arquivo, **Meu HUD** terá prioridade sobre os demais.
