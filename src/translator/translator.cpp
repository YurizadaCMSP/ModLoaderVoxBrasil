
/*
 * Mod Loader - Tradutor de Endereços entre Versões do Jogo
 * Copyright (C) 2013-2014 LINK/2012 <dma_2012@hotmail.com>
 *
 * Licenciado sob a Licença MIT.
 * Consulte o arquivo LICENSE localizado na raiz do projeto.
 *
 * Tradução PT-BR: VoxBrasil
 */

#include <modloader/modloader.hpp>
#include <modloader/util/injector.hpp>
#include <map>

using namespace injector;

// Tabelas de tradução
#include "gta3/sa/10us.hpp"
#include "gta3/sa/10eu.hpp"
#include "gta3/vc/10.hpp"
#include "gta3/3/10.hpp"

// Constantes
static const size_t max_ptr_dist = 8;   // Distância máxima para considerar um endereço equivalente.

static void init(std::map<memory_pointer_raw, memory_pointer_raw>& map);

// Variáveis externas
bool trying_address = false;    // Não exibe aviso quando um endereço não é encontrado.

// Traduz um ponteiro da versão GTA San Andreas 1.0 US
// para o endereço correspondente da versão atual do executável.
void* injector::address_manager::translator(void* p_)
{
    static std::map<memory_pointer_raw, memory_pointer_raw> map;

    // return p_;

    memory_pointer_raw p = p_;
    memory_pointer_raw result = nullptr;

    // Inicializa a tabela caso ainda não tenha sido criada.
    init(map);

    // Procura o primeiro endereço maior ou igual ao solicitado.
    auto it = map.lower_bound(p);

    if(it != map.end())
    {
        // Caso não seja exatamente o endereço procurado,
        // retorna uma posição anterior na tabela.
        if(it->first != p)
            --it;

        // Calcula a diferença entre os endereços.
        auto diff = uintptr_t(p - it->first);

        // Caso esteja dentro da distância permitida,
        // considera o endereço equivalente.
        if(diff <= max_ptr_dist)
            result = it->second + raw_ptr(diff);
    }

    // Caso a tradução não seja possível.
    if(!result)
    {
        if(!trying_address)
        {
            char buf[128];

            sprintf(
                buf,
                "Aviso: Não foi possível traduzir o endereço 0x%p",
                p.get<void>()
            );

#if NDEBUG
            // Versão Release
            if(modloader::plugin_ptr)
                modloader::plugin_ptr->Log(buf);
#else
            // Versão Debug
            if(modloader::plugin_ptr)
                modloader::plugin_ptr->Error(buf);
            else
                MessageBoxA(
                    0,
                    buf,
                    injector::game_version_manager::PluginName,
                    0
                );
#endif
        }
    }

    return result.get();
}


// Inicializa a tabela de tradução de endereços.
static void init(std::map<memory_pointer_raw, memory_pointer_raw>& map)
{
    static bool bInitialized = false;

    if(!bInitialized)
    {
        auto& gvm = injector::address_manager::singleton();

        bInitialized = true;

        // A tabela precisa possuir ponteiros nulos
        // em seus limites para que lower_bound()
        // funcione corretamente.
        map.emplace(0x00000000u, 0x00000000u);
        map.emplace(0xffffffffu, 0xffffffffu);

        // GTA San Andreas
        if(gvm.IsSA())
        {
            if(gvm.GetMajorVersion() == 1 &&
               gvm.GetMinorVersion() == 0 &&
               gvm.IsUS())
            {
                sa_10us(map);
            }
            else if(gvm.GetMajorVersion() == 1 &&
                    gvm.GetMinorVersion() == 0 &&
                    gvm.IsEU())
            {
                sa_10eu(map);
            }
        }

        // GTA Vice City
        else if(gvm.IsVC())
        {
            if(gvm.GetMajorVersion() == 1 &&
               gvm.GetMinorVersion() == 0)
            {
                vc_10(map);
            }
        }

        // GTA III
        else if(gvm.IsIII())
        {
            if(gvm.GetMajorVersion() == 1 &&
               gvm.GetMinorVersion() == 0)
            {
                III_10(map);
            }
        }
    }
}
