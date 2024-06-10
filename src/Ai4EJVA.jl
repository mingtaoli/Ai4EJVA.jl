module Ai4EJVA
using YAML
using Oxygen
const Ai4EJVA_VERSION = v"0.1.0"
const Ai4EJVA_AUTHOR = "Ai4Energy Team"
const CONFIG_ENV = "Ai4EJVA_CONFIG"
const CONFIG_DEFAULT_FILE = "etc/Ai4EJVA.yaml"
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
                config = args[i + 1]
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

    # try
    #     # 读取配置文件
    #     config = YAML.load_file(config_file)

    #     # 启动你的应用
    #     start_application(config)
    # catch e
    #     println("Error: ", e)
    #     return 1
    # end

    return 0

end

struct JWTConfig
    signing_key::String
    expires_time::String
    buffer_time::String
    issuer::String
end

struct SystemConfig
    db_type::String
    oss_type::String
    router_prefix::String
    addr::Int
    limit_count_ip::Int
    limit_time_ip::Int
    use_multipoint::Bool
    use_redis::Bool
    use_mongo::Bool
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
    cors::CORSConfig
end

mutable struct ServiceContext
    serverconfig::ServerConfig
    oxygencontext::Oxygen.Context
end

# 全局服务上下文变量
const SVCCONTEXT = Ref{ServiceContext}()

# struct DBApi end
# struct JwtApi end
# struct BaseApi end
# struct SystemApi end
# struct CasbinApi end
# struct AutoCodeApi end
# struct SystemApiApi end
# struct AuthorityApi end
# struct DictionaryApi end
# struct AuthorityMenuApi end
# struct OperationRecordApi end
# struct AutoCodeHistoryApi end
# struct DictionaryDetailApi end
# struct AuthorityBtnApi end
# struct SysExportTemplateApi end

# struct CustomerApi end
# struct FileUploadAndDownloadApi end

# # 定义系统 API 组
# struct SystemApiGroup
#     db_api::DBApi
#     jwt_api::JwtApi
#     base_api::BaseApi
#     system_api::SystemApi
#     casbin_api::CasbinApi
#     auto_code_api::AutoCodeApi
#     system_api_api::SystemApiApi
#     authority_api::AuthorityApi
#     dictionary_api::DictionaryApi
#     authority_menu_api::AuthorityMenuApi
#     operation_record_api::OperationRecordApi
#     auto_code_history_api::AutoCodeHistoryApi
#     dictionary_detail_api::DictionaryDetailApi
#     authority_btn_api::AuthorityBtnApi
#     sys_export_template_api::SysExportTemplateApi
# end

# # 定义示例 API 组
# struct ExampleApiGroup
#     customer_api::CustomerApi
#     file_upload_and_download_api::FileUploadAndDownloadApi
# end

# # 定义主 API 组
# struct ApiGroup
#     system_api_group::SystemApiGroup
#     example_api_group::ExampleApiGroup
# end

# # 创建全局变量
# const ApiGroupApp = ApiGroup(
#     SystemApiGroup(
#         DBApi(),
#         JwtApi(),
#         BaseApi(),
#         SystemApi(),
#         CasbinApi(),
#         AutoCodeApi(),
#         SystemApiApi(),
#         AuthorityApi(),
#         DictionaryApi(),
#         AuthorityMenuApi(),
#         OperationRecordApi(),
#         AutoCodeHistoryApi(),
#         DictionaryDetailApi(),
#         AuthorityBtnApi(),
#         SysExportTemplateApi()
#     ),
#     ExampleApiGroup(
#         CustomerApi(),
#         FileUploadAndDownloadApi()
#     )
# )


# # 定义空类型，用于多重分发
# abstract type RouterGroup end
# struct PublicGroup <: RouterGroup end
# struct PrivateGroup <: RouterGroup end

# # 定义不同的路由初始化函数
# function initiate_route(router, ::Type{PublicGroup})
#     InitBaseRouter(router, "/public")
#     InitInitRouter(router, "/public")
# end

# function initiate_route(router, ::Type{PrivateGroup})
#     InitApiRouter(router, "/private")
#     InitJwtRouter(router, "/private")
#     InitUserRouter(router, "/private")
# end

# function InitBaseRouter(router, group::AbstractString)
#     HTTP.@register(router, "GET", group * "/base", req -> HTTP.Response(200, "Base Router"))
# end

# # 改成InitRouter(a::BaseRouter)
# # InitRouter(b::InitRouter)
# # 等多重分发形式

# function InitInitRouter(router, group::AbstractString)
#     HTTP.@register(router, "GET", group * "/init", req -> HTTP.Response(200, "Init Router"))
# end

# function InitApiRouter(router, group::AbstractString)
#     HTTP.@register(router, "GET", group * "/api", req -> HTTP.Response(200, "API Router"))
# end

# function InitJwtRouter(router, group::AbstractString)
#     HTTP.@register(router, "GET", group * "/jwt", req -> HTTP.Response(200, "JWT Router"))
# end

# function InitUserRouter(router, group::AbstractString)
#     HTTP.@register(router, "GET", group * "/user", req -> HTTP.Response(200, "User Router"))
# end

# # 添加其他需要的路由初始化函数...

# # 初始化路由器
# function initialize_routers()
#     router = HTTP.Router()

#     # 添加静态文件路由
#     HTTP.servefiles(router, "/form-generator" => "./resource/page")

#     # 添加Swagger路由（作为示例）
#     HTTP.@register(router, "GET", "/swagger", req -> HTTP.Response(200, "Swagger Handler"))

#     # 公共路由组
#     HTTP.@register(router, "GET", "/public/health", req -> HTTP.Response(200, JSON.json("ok")))
#     initiate_route(router, PublicGroup)

#     # 私有路由组
#     HTTP.@register(router, "GET", "/private/auth", req -> HTTP.Response(200, "Auth Middleware"))  # 示例中间件
#     initiate_route(router, PrivateGroup)

#     return router
# end



# # 根据配置中的数据库类型连接相应的数据库
# function ConnectDB()
#     db_type = GAPHD_CONFIG["System"]["DbType"]
#     if db_type == "mysql"
#         return ConnectMysql()
#     elseif db_type == "pgsql"
#         return ConnectPgSql()
#     elseif db_type == "oracle"
#         return ConnectOracle()
#     elseif db_type == "mssql"
#         return ConnectMssql()
#     elseif db_type == "sqlite"
#         return ConnectSqlite()
#     else
#         error("Unsupported database type: $db_type")
#     end
# end


# # 初始化多个数据库连接并存储在全局变量中
# function MultiDBConnect()
#     db_map = Dict{String, Any}()
#     for info in GAPHD_CONFIG["DBList"]
#         if info["Disable"]
#             continue
#         end
#         db_config = info["GeneralDB"]
#         alias_name = info["AliasName"]
#         db_type = info["Type"]
#         if db_type == "mysql"
#             db_map[alias_name] = ConnectMysqlByConfig(db_config)
#         elseif db_type == "pgsql"
#             db_map[alias_name] = ConnectPgSqlByConfig(db_config)
#         elseif db_type == "oracle"
#             db_map[alias_name] = ConnectOracleByConfig(db_config)
#         elseif db_type == "mssql"
#             db_map[alias_name] = ConnectMssqlByConfig(db_config)
#         else
#             continue
#         end
#     end
#     # 适配低版本迁移多数据库版本
#     if haskey(db_map, "sys")
#         GAPHD_DB["sys"] = db_map["sys"]
#     end
#     GAPHD_DBList = db_map
# end

# # 数据模型示例
# function create_tables(db::SQLite.DB)
#     execute(db, """
#         CREATE TABLE IF NOT EXISTS SysApi (
#             id INTEGER PRIMARY KEY,
#             name TEXT
#         );
#     """)

#     execute(db, """
#         CREATE TABLE IF NOT EXISTS SysUser (
#             id INTEGER PRIMARY KEY,
#             username TEXT,
#             password TEXT
#         );
#     """)

#     # 添加其他表的创建语句
#     execute(db, """
#         CREATE TABLE IF NOT EXISTS ExaFile (
#             id INTEGER PRIMARY KEY,
#             filename TEXT,
#             filepath TEXT
#         );
#     """)

#     # 添加更多表的创建语句，根据你的需求
# end

# # 注册表函数
# function RegisterTables()
#     db = GAPHD_DB[]

#     try
#         create_tables(db)
#         info(GAPHD_LOG, "Register tables success")
#     catch e
#         error(GAPHD_LOG, "Register tables failed: $e")
#         exit(1)
#     end
# end


# # 定义一个简单的计时器结构体和相关函数
# mutable struct Timer
#     start_time::Float64
#     end_time::Float64
# end

# function start_timer(timer::Timer)
#     timer.start_time = time()
# end

# function stop_timer(timer::Timer)
#     timer.end_time = time()
# end

# function elapsed_time(timer::Timer)::Float64
#     return timer.end_time - timer.start_time
# end

# # 获取DB函数
# function get_global_db_by_dbname(dbname::String)::DataFrame
#     return haskey(Ai4EJVA_DBList, dbname) ? Ai4EJVA_DBList[dbname] : DataFrame()
# end

# # 必须获取DB函数
# function must_get_global_db_by_dbname(dbname::String)::DataFrame
#     if !haskey(Ai4EJVA_DBList, dbname)
#         error("db no init")
#     end
#     return Ai4EJVA_DBList[dbname]
# end

# # 示例结构体
# mutable struct GVA_MODEL
#     ID::Int64
#     CreatedAt::DateTime
#     UpdatedAt::DateTime
#     DeletedAt::Union{Nothing, DateTime}

#     GVA_MODEL() = new(0, now(), now(), nothing)
# end

# # 启动服务器
# function run_server()
#     if GAPHD_CONFIG["System"]["UseMultipoint"] || GAPHD_CONFIG["System"]["UseRedis"]
#         initialize_redis()
#     end

#     if GAPHD_CONFIG["System"]["UseMongo"]
#         initialize_mongo()
#     end

#     load_all_from_db()

#     router = initialize_routers()
#     address = GAPHD_CONFIG["System"]["Addr"]
#     server_address = "0.0.0.0:$address"
#     info(GAPHD_LOG, "Server running on $server_address")

#     println("""
#     欢迎使用 gin-vue-admin
#     当前版本:v2.6.5
#     加群方式:微信号：shouzi_1994 QQ群：470239250
#     项目地址：https://github.com/flipped-aurora/gin-vue-admin
#     插件市场:https://plugin.gin-vue-admin.com
#     GVA讨论社区:https://support.qq.com/products/371961
# **
#     """)

#     HTTP.serve(router, server_address)
# end

end # module Ai4EJVA
