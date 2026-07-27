# Criando Seu Próprio Plugin (Loader) para o Mod Loader
=======================================================

O **Mod Loader** é totalmente baseado em plugins. Essa arquitetura torna o sistema mais modular e independente, pois cada plugin é responsável por lidar com um determinado tipo de arquivo.

A comunicação entre o núcleo do Mod Loader e seus plugins é feita por meio de uma **API em C baseada em eventos**. No entanto, também existe uma **interface em C++**, que é mais prática e recomendada para novos desenvolvimentos.

Neste documento abordaremos apenas a interface em **C++**.

---

# Interface C++

Como mencionado anteriormente, a comunicação entre o Mod Loader e um plugin acontece através de eventos.

Para criar um plugin, será necessário implementar uma classe que responda a esses eventos e compilá-la como uma biblioteca dinâmica (**DLL**).

> **Importante:** Não implemente uma função `DllMain()` no seu plugin.

---

## Incluindo a API

Para utilizar a interface C++, inclua o seguinte cabeçalho:

```cpp
#include <modloader/modloader.hpp>
```

Esse arquivo está localizado na pasta **include/** da árvore de código-fonte.

---

## Criando um plugin

O primeiro passo é criar uma classe derivada de:

```cpp
modloader::basic_plugin
```

Você também pode utilizar como base o arquivo:

```text
src/plugins/template.cpp
```

Depois disso, registre seu plugin utilizando a macro:

```cpp
REGISTER_ML_PLUGIN(plugin)
```

Agora basta implementar os eventos (métodos virtuais) fornecidos por `modloader::basic_plugin`.

---

# Eventos

## GetInfo

```cpp
const info& GetInfo()
```

Este método deve retornar uma referência para um objeto estático do tipo:

```cpp
modloader::basic_plugin::info
```

Estrutura:

```cpp
struct info
{
    const char*  name;
    const char*  version;
    const char*  author;
    int          default_priority;
    const char** extable;
};
```

### Campos

### name

Nome do plugin.

Atualmente este campo não é utilizado internamente, mas deve conter o nome do plugin.

---

### version

Versão do plugin.

---

### author

Autor do plugin.

Pode ser:

```cpp
nullptr
```

caso não deseje informar.

---

### default_priority

Prioridade padrão dos eventos do plugin em relação aos demais plugins.

Utilize:

```cpp
-1
```

para usar a prioridade padrão.

---

### extable

Lista das extensões de arquivos suportadas pelo plugin.

Exemplo:

```cpp
.dff
.txd
.ide
.dat
```

A lista deve terminar obrigatoriamente com:

```cpp
nullptr
```

> **Observação:** Essa lista serve apenas para otimizar a busca. O plugin ainda poderá receber arquivos com outras extensões.

---

# OnStartup

```cpp
bool OnStartup()
```

**Opcional.**

Chamado quando o plugin é inicializado.

A ordem de inicialização dos plugins não é garantida.

Retorne:

```cpp
true
```

caso a inicialização tenha ocorrido com sucesso.

ou

```cpp
false
```

caso contrário.

Quando `false` é retornado, o plugin será descarregado imediatamente, sem chamar `OnShutdown()`.

Um uso comum é impedir que o plugin seja carregado em jogos incompatíveis.

---

# OnShutdown

```cpp
bool OnShutdown()
```

**Opcional.**

Chamado quando o plugin é encerrado.

Retorne:

```cpp
true
```

em caso de sucesso.

ou

```cpp
false
```

caso contrário.

> Atualmente esse valor de retorno não possui efeito prático, mas recomenda-se implementá-lo corretamente para futuras versões.

---

# GetBehaviour

```cpp
int GetBehaviour(modloader::file& file)
```

Este evento informa ao Mod Loader se este plugin será responsável por manipular determinado arquivo.

Retorne um dos seguintes valores:

### MODLOADER_BEHAVIOUR_NO

O plugin não manipula este arquivo.

---

### MODLOADER_BEHAVIOUR_YES

O plugin manipula este arquivo.

Neste caso, é obrigatório definir:

```cpp
file.behaviour
```

Esse campo identifica o comportamento exclusivo daquele arquivo.

Arquivos com o mesmo comportamento não podem permanecer instalados ao mesmo tempo.

Exemplo:

```
a.model
```

possui o mesmo comportamento que outro:

```
a.model
```

mas diferente de:

```
b.model
```

Quando um novo arquivo com o mesmo comportamento é instalado, o anterior é automaticamente removido.

---

### MODLOADER_BEHAVIOUR_CALLME

O plugin não é responsável por esse arquivo, mas deseja receber notificações durante:

- instalação;
- reinstalação;
- remoção.

---

### Observações

- O bit mais alto de `behaviour` é reservado e não deve ser alterado.
- Durante este evento, o único campo do objeto `file` que pode ser modificado é:

```cpp
behaviour
```

---

# InstallFile

```cpp
bool InstallFile(const modloader::file& file)
```

Chamado quando um arquivo será instalado.

Se já existir outro arquivo com o mesmo comportamento, ele será automaticamente removido antes.

Retorne:

```cpp
true
```

em caso de sucesso.

ou

```cpp
false
```

caso contrário.

> O valor de retorno é ignorado para plugins que utilizam `CALLME`.

---

# ReinstallFile

```cpp
bool ReinstallFile(const modloader::file& file)
```

Chamado quando um arquivo previamente instalado foi alterado.

O comportamento do arquivo permanece o mesmo.

Retorne:

```cpp
true
```

caso a reinstalação seja bem-sucedida.

Caso retorne:

```cpp
false
```

o arquivo será automaticamente desinstalado.

Assim como em `InstallFile`, o retorno é ignorado para plugins `CALLME`.

---

# UninstallFile

```cpp
bool UninstallFile(const modloader::file& file)
```

Chamado quando um arquivo precisa ser removido.

Retorne:

```cpp
true
```

caso a remoção seja concluída.

Se retornar:

```cpp
false
```

o arquivo continuará marcado como instalado.

O retorno também é ignorado para plugins `CALLME`.

---

# Update

```cpp
void Update()
```

**Opcional.**

Chamado após uma sequência de chamadas para:

- InstallFile
- ReinstallFile
- UninstallFile

Utilize esse evento para atualizar estados internos do plugin, caso necessário.

---

# Objetos do Mod Loader

## modloader::basic_plugin

Classe base utilizada para criar plugins.

Ela fornece diversas funções úteis.

### loader

Contém informações gerais sobre o Mod Loader, como:

- caminho do jogo;
- estado da inicialização;
- informações da instalação.

---

### Log()

```cpp
Log(fmt, ...)
```

Grava mensagens no arquivo de log do Mod Loader.

Também existe:

```cpp
vLog(fmt, va_list)
```

---

### Error()

```cpp
Error(fmt, ...)
```

Exibe uma caixa de mensagem de erro ao usuário.

---

### cast<To>()

Permite converter um objeto derivado de `basic_plugin` para outro tipo.

---

## modloader::plugin_ptr

Ponteiro global para o plugin registrado através de:

```cpp
REGISTER_ML_PLUGIN()
```

---

## modloader::plugin

Representa um plugin registrado no Mod Loader.

Atualmente possui pouca utilidade para desenvolvedores de plugins.

---

## modloader::mod

Representa um mod carregado pelo Mod Loader.

Na prática, corresponde a uma pasta localizada dentro de:

```text
modloader/
```

---

## modloader::file

Representa um arquivo pertencente a um mod.

Esse é o objeto mais importante para quem desenvolve plugins.

Ele contém diversas informações, como:

- caminho completo;
- nome;
- hash;
- tamanho;
- extensão;
- comportamento;
- e outros dados.

Consulte:

```text
include/modloader.hpp
```

para conhecer todos os seus campos.

---

# Tempo de vida dos objetos

Os objetos:

- `modloader::file`
- `modloader::mod`
- `modloader::plugin`

permanecem válidos desde o momento em que são recebidos em:

```cpp
InstallFile()
```

até o retorno de:

```cpp
UninstallFile()
```

Portanto, é seguro armazenar seus ponteiros durante esse período.

Entretanto, **não é garantido** que eles permaneçam válidos:

- após `GetBehaviour()`;
- durante `Update()` caso o arquivo já tenha sido removido.

---

# Exemplos

Você pode encontrar exemplos completos em:

```text
src/plugins/
```

ou utilizar como base o arquivo:

```text
src/plugins/template.cpp
```

---

# Cabeçalhos Utilitários

Além dos arquivos principais da API:

```text
include/modloader.h
include/modloader.hpp
```

o projeto disponibiliza diversos cabeçalhos auxiliares em:

```text
include/modloader/util/
```

Esses arquivos oferecem funções utilitárias para facilitar o desenvolvimento de plugins, evitando a necessidade de implementar tarefas comuns manualmente.
