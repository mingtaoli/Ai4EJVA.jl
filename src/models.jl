# ------------------------------------------------
# 请求结构体
# ------------------------------------------------
struct RegisterRequest
    username::String
    password::String
    nickname::String
    header_img::String
    authority_id::UInt
    enable::Int
    authority_ids::Vector{UInt}
    phone::String
    email::String
end

struct LoginRequest
    username::String
    password::String
    captcha::String
    captcha_id::String
end

struct ChangePasswordRequest
    id::UInt
    password::String
    new_password::String
end

struct SetUserAuthRequest
    authority_id::UInt
end

struct SetUserAuthoritiesRequest
    id::UInt
    authority_ids::Vector{UInt}
end

struct ChangeUserInfoRequest
    id::UInt
    nickname::String
    phone::String
    authority_ids::Vector{UInt}
    email::String
    header_img::String
    side_mode::String
    enable::Int
    authorities::Vector{System.SysAuthority}
end

struct UserLoginResponse
    userid::Int64
    loginname::String
    token::String
end
# ------------------------------------------------
# 响应结构体
# ------------------------------------------------

# ------------------------------------------------
# 其余结构体
# ------------------------------------------------