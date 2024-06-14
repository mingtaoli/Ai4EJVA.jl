module Ai4EJVA
using YAML
using Oxygen
include("models.jl")
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

abstract type ModelDriver end

mutable struct ServiceContext
    serverconfig::ServerConfig
    oxygencontext::Oxygen.Context
    # 以下这行，就有点仿go-zero的那个意思了，go-zero中svc抓住了各个模型的，具体怎么设置这个字段再讨论
    model_drivers::Dict{String, ModelDriver}
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
    empty_dict = Dict{String, ModelDriver}()
    SVCCONTEXT[] = ServiceContext(config, oxygencontext,empty_dict)
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
        InitRouter()
        #每个模块中说不定还得改一下svc变量呢。
        Oxygen.serve()
    catch e
        println("Error: ", e)
        return 1
    end
    return 0
end

module ModuleA
    using Oxygen
    function InitRouter()
        println("Initializing router for ModuleA")
        # 在这里添加 ModuleA 的路由初始化代码
    end
end
module ModuleB
    # 把不同的Module做成package，using它就好
    function UserLogin(request::HTTP.Request) #这是handler
    # 先做反序列化得到LoginRequest
    loginrequest = json(request, LoginRequest)
    
    # 如果需要才调用外部函数处理登录逻辑 否则，直接把logic写在这里就可以了。
    response = "hello"

    end
    function InitRouter()
        println("Initializing router for ModuleB")
        Oxygen.route([Oxygen.POST], "/user/login", UserLogin)
        # 在这里添加 ModuleB 的路由初始化代码
    end
end

function InitRouter()
    println("Initializing main router")
    ModuleA.InitRouter()
    ModuleB.InitRouter()
    # 可以根据需要添加更多模块的路由初始化
end


# 这个就是类似go-zero中的logic函数，如非必要不要这个单独的userlogic，直接在handler里写就很好了。
function login(loginrequest::LoginRequest, svc_ctx::ServiceContext)::UserLoginResponse
#logic here 这个函数就是logic处理函数
end


end # module Ai4EJVA
