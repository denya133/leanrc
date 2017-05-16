module.exports =
  port:
    description: "port for start tomatos server"
    type: "number"
    default: 3001

  secret:
    description: "Secret key for encoding and decoding tokens."
    type: "string"
    default: "_!%9^Zx75!Kd_!%afG"

  apiKey:
    description: "Secret key allowing interactions between servers"
    type: "string"
    default: "%%Xr2rN+gt8JA3tx=UUyCtx=d_!%9#qz^Zx75!Kd_!%afGpeh822Wh34T7ngZ"

  adminPassword:
    description: "Admin password."
    type: "string"
    default: "1111"

  cucumbersServer:
    description: "URL for cucumbers server"
    type: "json"
    default:
      host: "http://127.0.0.1:3002"
      namespace: '0.1'
