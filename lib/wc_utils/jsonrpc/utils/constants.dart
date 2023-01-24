import 'package:wallet_connect_v2/wc_utils/jsonrpc/models/models.dart';

const PARSE_ERROR = "PARSE_ERROR";
const INVALID_REQUEST = "INVALID_REQUEST";
const METHOD_NOT_FOUND = "METHOD_NOT_FOUND";
const INVALID_PARAMS = "INVALID_PARAMS";
const INTERNAL_ERROR = "INTERNAL_ERROR";
const SERVER_ERROR = "SERVER_ERROR";

const RESERVED_ERROR_CODES = [-32700, -32600, -32601, -32602, -32603];
const SERVER_ERROR_CODE_RANGE = [-32000, -32099];

const STANDARD_ERROR_MAP = {
  PARSE_ERROR: ErrorResponse(code: -32700, message: "Parse error"),
  INVALID_REQUEST: ErrorResponse(code: -32600, message: "Invalid Request"),
  METHOD_NOT_FOUND: ErrorResponse(code: -32601, message: "Method not found"),
  INVALID_PARAMS: ErrorResponse(code: -32602, message: "Invalid params"),
  INTERNAL_ERROR: ErrorResponse(code: -32603, message: "Internal error"),
  SERVER_ERROR: ErrorResponse(code: -32000, message: "Server error"),
};

const DEFAULT_ERROR = SERVER_ERROR;
