# Argumentos de Linha de Comando do Mod Loader
=============================================

O **Mod Loader** permite utilizar argumentos de linha de comando ao iniciar o executável do jogo. Esses parâmetros possibilitam controlar quais mods ou perfis serão carregados durante a execução.

---

# -nomods

Impede que qualquer mod presente na pasta **modloader** seja carregado.

### Uso

```text
gta_sa.exe -nomods
```

### Resultado

O jogo será iniciado sem carregar nenhuma modificação do Mod Loader.

---

# -mod NomeDoMod

Faz com que o Mod Loader carregue apenas o mod especificado na pasta **modloader**.

Na prática, esse comando possui o mesmo efeito que criar um perfil com:

- `ExcludeAllMods = true`
- O mod listado em `[IncludeMods]`

### Uso

```text
gta_sa.exe -mod NomeDoMod
```

### Exemplo

```text
gta_sa.exe -mod MeuHUD
```

O Mod Loader carregará apenas:

```text
modloader/MeuHUD
```

com prioridade padrão **20**.

> Você pode utilizar esse parâmetro várias vezes para carregar diversos mods.

Exemplo:

```text
gta_sa.exe -mod MeuHUD -mod SkyGFX -mod Project2DFX
```

---

# -mod NomeDoMod=Prioridade

Funciona da mesma forma que `-mod`, porém permite definir uma prioridade personalizada para o mod.

### Uso

```text
gta_sa.exe -mod NomeDoMod=Prioridade
```

### Exemplo

```text
gta_sa.exe -mod MeuHUD=100
```

Neste caso:

- Apenas o mod **MeuHUD** será carregado;
- Sua prioridade será **100**.

---

# -modprof NomeDoPerfil

Carrega um perfil específico do Mod Loader.

### Uso

```text
gta_sa.exe -modprof MeuPerfil
```

### Exemplo

```text
gta_sa.exe -modprof SAMP
```

O Mod Loader utilizará todas as configurações definidas no perfil **SAMP**.

---

# Observações

- Os parâmetros `-nomods`, `-mod` e `-modprof` são **mutuamente exclusivos**. Ou seja, apenas um deles pode ser utilizado por vez.

- Quando `-mod` ou `-modprof` são utilizados, o Mod Loader cria um **perfil temporário (anônimo)** durante a execução do jogo.

- Alterações feitas nesse perfil temporário **não serão salvas** e também **não substituirão** o perfil original.

---

# Exemplos

### Iniciar o jogo sem mods

```text
gta_sa.exe -nomods
```

### Carregar apenas um mod

```text
gta_sa.exe -mod SkyGFX
```

### Carregar vários mods

```text
gta_sa.exe -mod SkyGFX -mod Project2DFX -mod MeuHUD
```

### Carregar um mod com prioridade personalizada

```text
gta_sa.exe -mod MeuHUD=100
```

### Iniciar utilizando um perfil

```text
gta_sa.exe -modprof SAMP
```
