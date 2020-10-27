require "json"

module Ripple::Response
  class Memos
    JSON.mapping(
      data: String?,
      format: String?,
      type: String?
    )
  end
end
