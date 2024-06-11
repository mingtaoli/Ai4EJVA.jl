module Ai4EJVA
using YAML
using Oxygen
const Ai4EJVA_VERSION = v"0.1.0"
const Ai4EJVA_AUTHOR = "Ai4Energy Team"
const CONFIG_ENV = "Ai4EJVA_CONFIG"
const CONFIG_DEFAULT_FILE = joinpath(@__DIR__, "..", "etc", "Ai4EJVA.yaml")
const CONFIG_TEST_FILE = "etc/test.yml"
const CONFIG_DEBUG_FILE = "etc/debug.yml"

const HELP_INFO = """
This is Ai4EJVA.jl $Ai4EJVA_VERSION by $Ai4EJVA_AUTHOR.

Usage:

Ai4EJVA [-c config.yaml] [--version] [--help]

Options:
  -c, --config    Path to the configuration file (default: Ai4EJVA.yaml)
  -v, --version   Show version information
  -h, --help      Show this help message and exit

If no config file is specified, the default is Ai4EJVA.yaml.
"""

struct JWTConfig
    signing_key::String
    expires_time::String
    buffer_time::String
    issuer::String
end

mutable struct SystemConfig
    env::String
    addr::Int
    db_type::String
    use_redis::Bool
    use_mongo::Bool
    use_multipoint::Bool
    iplimit_count::Int
    iplimit_time::Int
    router_prefix::String
end

struct EmailConfig
    to::String
    from::String
    host::String
    secret::String
    nickname::String
    port::Int
    is_ssl::Bool
end

struct PgsqlConfig
    host::String
    port::Int
    username::String
    password::String
    database::String
end

struct CORSWhitelistConfig
    allow_origin::String
    allow_methods::String
    allow_headers::String
    expose_headers::String
    allow_credentials::Bool
end

struct CORSConfig
    mode::String
    whitelist::Vector{CORSWhitelistConfig}
end

struct ServerConfig
    jwt::JWTConfig
    email::EmailConfig
    system::SystemConfig
    pgsql::PgsqlConfig
    # cors::CORSConfig
end

mutable struct ServiceContext
    serverconfig::ServerConfig
    oxygencontext::Oxygen.Context
end

const SVCCONTEXT = Ref{ServiceContext}()

function show_help()
    println(HELP_INFO)
end

function show_version()
    println("Ai4EJVA.jl version $Ai4EJVA_VERSION by $Ai4EJVA_AUTHOR")
end

function parse_args(args)
    config = ""
    show_help_flag = false
    show_version_flag = false
    i = 1
    while i <= length(args)
        arg = args[i]
        if arg == "-c" || arg == "--config"
            if i + 1 <= length(args)
                config = args[i+1]
                i += 1
            else
                println("Error: --config option requires a value")
                return nothing
            end
        elseif arg == "-v" || arg == "--version"
            show_version_flag = true
        elseif arg == "-h" || arg == "--help"
            show_help_flag = true
        else
            println("Error: Unrecognized argument $arg")
            return nothing
        end
        i += 1
    end
    return (config, show_help_flag, show_version_flag)
end

function load_config(filename::String)
    config = YAML.load_file(filename)
    jwt_config = JWTConfig(
        config["jwt"]["signing-key"],
        config["jwt"]["expires-time"],
        config["jwt"]["buffer-time"],
        config["jwt"]["issuer"]
    )
    email_config = EmailConfig(
        config["email"]["to"],
        config["email"]["from"],
        config["email"]["host"],
        config["email"]["secret"],
        config["email"]["nickname"],
        config["email"]["port"],
        config["email"]["is_ssl"]
    )
    system_config = SystemConfig(
        config["system"]["env"],
        config["system"]["addr"],
        config["system"]["db-type"],
        config["system"]["use-redis"],
        config["system"]["use-mongo"],
        config["system"]["use-multipoint"],
        config["system"]["iplimit-count"],
        config["system"]["iplimit-time"],
        config["system"]["router-prefix"]
    )
    pgsql_config = PgsqlConfig(
        config["pgsql"]["host"],
        config["pgsql"]["port"],
        config["pgsql"]["username"],
        config["pgsql"]["password"],
        config["pgsql"]["database"]
    )
    # cors_config=CORSConfig(

    # )
    ServerConfig(
        jwt_config,
        email_config,
        system_config,
        pgsql_config)
end

function setup_service_context(config::ServerConfig)::ServiceContext
    oxygencontext = Oxygen.CONTEXT[]
    SVCCONTEXT[] = ServiceContext(config, oxygencontext)
end

function julia_main()::Cint
    args = ARGS
    parsed_args = parse_args(args)
    if parsed_args === nothing
        return 1
    end
    config, show_help_flag, show_version_flag = parsed_args
    if show_help_flag
        show_help()
        return 0
    elseif show_version_flag
        show_version()
        return 0
    end
    if config == ""
        config = get(ENV, CONFIG_ENV, CONFIG_DEFAULT_FILE)
    end
    println("Using configuration file: $config")
    try
        #     # 读取配置文件
        serverconfig = load_config(config)
        setup_service_context(serverconfig)
        InitRouter(ApiGroupApp)
        Oxygen.serve()
    catch e
        println("Error: ", e)
        return 1
    end
    return 0
end

struct DBApi end
struct JwtApi end
struct BaseApi end
struct SystemApi end
struct CasbinApi end
struct AutoCodeApi end
struct SystemApiApi end
struct AuthorityApi end
struct DictionaryApi end
struct AuthorityMenuApi end
struct OperationRecordApi end
struct AutoCodeHistoryApi end
struct DictionaryDetailApi end
struct AuthorityBtnApi end
struct SysExportTemplateApi end
struct CustomerApi end
struct FileUploadAndDownloadApi end

# 定义系统 API 组
struct SystemApiGroup
    db_api::DBApi
    jwt_api::JwtApi
    base_api::BaseApi
    system_api::SystemApi
    casbin_api::CasbinApi
    auto_code_api::AutoCodeApi
    system_api_api::SystemApiApi
    authority_api::AuthorityApi
    dictionary_api::DictionaryApi
    authority_menu_api::AuthorityMenuApi
    operation_record_api::OperationRecordApi
    auto_code_history_api::AutoCodeHistoryApi
    dictionary_detail_api::DictionaryDetailApi
    authority_btn_api::AuthorityBtnApi
    sys_export_template_api::SysExportTemplateApi
end

# 定义示例 API 组
struct ExampleApiGroup
    customer_api::CustomerApi
    file_upload_and_download_api::FileUploadAndDownloadApi
end

# 定义主 API 组
struct ApiGroup
    system_api_group::SystemApiGroup
    example_api_group::ExampleApiGroup
end

# 创建全局变量
const ApiGroupApp = ApiGroup(
    SystemApiGroup(
        DBApi(),
        JwtApi(),
        BaseApi(),
        SystemApi(),
        CasbinApi(),
        AutoCodeApi(),
        SystemApiApi(),
        AuthorityApi(),
        DictionaryApi(),
        AuthorityMenuApi(),
        OperationRecordApi(),
        AutoCodeHistoryApi(),
        DictionaryDetailApi(),
        AuthorityBtnApi(),
        SysExportTemplateApi()
    ),
    ExampleApiGroup(
        CustomerApi(),
        FileUploadAndDownloadApi()
    )
)

function UserLogin(req)
    return Oxygen.Response(200, "User Login")
end

# 路由初始化函数
function InitRouter(router::DBApi, group::AbstractString)
    Oxygen.route([Oxygen.POST], "/user/login", UserLogin)
    #这里学习一下oxygen的文档，看如何进行group
end


function InitRouter(router::JwtApi, group::AbstractString)
    Oxygen.route([Oxygen.POST], "/user/login", UserLogin)
end

function InitRouter(router::BaseApi, group::AbstractString)
    Oxygen.route([Oxygen.POST], "/user/login", UserLogin)
end

function InitRouter(router::SystemApi, group::AbstractString)
    Oxygen.route([Oxygen.POST], "/user/login", UserLogin)
end

# 多重分发的路由组初始化函数
function InitRouter(api_group::SystemApiGroup, ::Type{PublicGroup})
    InitRouter(api_group.db_api, "/public")
    InitRouter(api_group.jwt_api, "/public")
    InitRouter(api_group.base_api, "/public")
    InitRouter(api_group.system_api, "/public")
    # 初始化其他 API 路由...
end

function InitRouter(api_group::SystemApiGroup, ::Type{PrivateGroup})
    InitRouter(api_group.db_api, "/private")
    InitRouter(api_group.jwt_api, "/private")
    InitRouter(api_group.base_api, "/private")
    InitRouter(api_group.system_api, "/private")
    # 初始化其他 API 路由...
end

function InitRouter(api_group::ExampleApiGroup, ::Type{PublicGroup})
    InitRouter(api_group.customer_api, "/public")
    InitRouter(api_group.file_upload_and_download_api, "/public")
end

function InitRouter(api_group::ExampleApiGroup, ::Type{PrivateGroup})
    InitRouter(api_group.customer_api, "/private")
    InitRouter(api_group.file_upload_and_download_api, "/private")
end

function InitRouter(api_group::ApiGroup)
    InitRouter(api_group.system_api_group, ::Type{PublicGroup})
    InitRouter(api_group.system_api_group, ::Type{PrivateGroup})
    InitRouter(api_group.example_api_group, ::Type{PublicGroup})
    InitRouter(api_group.example_api_group, ::Type{PrivateGroup})
end

end # module Ai4EJVA
