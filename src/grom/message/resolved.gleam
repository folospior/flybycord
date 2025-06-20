import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/option.{type Option, None}
import grom/channel
import grom/channel/guild/thread
import grom/guild/member.{type Member}
import grom/guild/role.{type Role}
import grom/message/attachment.{type Attachment}
import grom/permission.{type Permission}
import grom/user.{type User}

// TYPES -----------------------------------------------------------------------

// DECODERS --------------------------------------------------------------------

@internal
pub fn decoder() -> decode.Decoder(Resolved) {
  use users <- decode.optional_field(
    "users",
    None,
    decode.optional(decode.dict(decode.string, user.decoder())),
  )
  use members <- decode.optional_field(
    "members",
    None,
    decode.optional(decode.dict(decode.string, member.decoder())),
  )
  use roles <- decode.optional_field(
    "roles",
    None,
    decode.optional(decode.dict(decode.string, role.decoder())),
  )
  use channels <- decode.optional_field(
    "channels",
    None,
    decode.optional(decode.dict(decode.string, partial_channel_decoder())),
  )
  use attachments <- decode.optional_field(
    "attachments",
    None,
    decode.optional(decode.dict(decode.string, attachment.decoder())),
  )
  decode.success(Resolved(users:, members:, roles:, channels:, attachments:))
}

@internal
pub fn partial_channel_decoder() -> decode.Decoder(PartialChannel) {
  use variant <- decode.field("type", channel.type_decoder())
  case variant {
    channel.AnnouncementThreadChannel
    | channel.PublicThreadChannel
    | channel.PrivateThreadChannel -> {
      use id <- decode.field("id", decode.string)
      use name <- decode.field("name", decode.string)
      use type_ <- decode.field("type", channel.type_decoder())
      use permissions <- decode.field("permissions", permission.decoder())
      use metadata <- decode.field("metadata", thread.metadata_decoder())
      use parent_id <- decode.field("parent_id", decode.string)
      decode.success(PartialThread(
        id:,
        name:,
        type_:,
        permissions:,
        metadata:,
        parent_id:,
      ))
    }
    _ -> {
      use id <- decode.field("id", decode.string)
      use name <- decode.field("name", decode.string)
      use type_ <- decode.field("type", channel.type_decoder())
      use permissions <- decode.field("permissions", permission.decoder())
      decode.success(PartialChannel(id:, name:, type_:, permissions:))
    }
  }
}
