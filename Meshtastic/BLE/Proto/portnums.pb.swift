// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: portnums.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

///
/// For any new 'apps' that run on the device or via sister apps on phones/PCs they should pick and use a
/// unique 'portnum' for their application.
///
/// If you are making a new app using meshtastic, please send in a pull request to add your 'portnum' to this
/// master table.  PortNums should be assigned in the following range:
///
/// 0-63   Core Meshtastic use, do not use for third party apps
/// 64-127 Registered 3rd party apps, send in a pull request that adds a new entry to portnums.proto to  register your application
/// 256-511 Use one of these portnums for your private applications that you don't want to register publically
///
/// All other values are reserved.
///
/// Note: This was formerly a Type enum named 'typ' with the same id #
///
/// We have change to this 'portnum' based scheme for specifying app handlers for particular payloads.  
/// This change is backwards compatible by treating the legacy OPAQUE/CLEAR_TEXT values identically.
enum PortNum: SwiftProtobuf.Enum {
  typealias RawValue = Int

  ///
  /// Deprecated: do not use in new code (formerly called OPAQUE)
  /// A message sent from a device outside of the mesh, in a form the mesh does not understand 
  /// NOTE: This must be 0, because it is documented in IMeshService.aidl to be so
  case unknownApp // = 0

  ///
  /// A simple UTF-8 text message, which even the little micros in the mesh
  /// can understand and show on their screen eventually in some circumstances
  /// even signal might send messages in this form (see below)
  /// Formerly called CLEAR_TEXT
  case textMessageApp // = 1

  ///
  /// A message receive acknowledgement, sent in cleartext - allows radio to
  /// show user that a message has been read by the recipient, optional
  ///
  /// Note: this concept has been removed for now.  Once READACK is implemented, use the 
  /// new packet type/port number stuff?
  ///
  /// @exclude
  ///
  /// CLEAR_READACK = 2;
  ///
  /// Reserved for built-in GPIO/example app.
  /// See remote_hardware.proto/HardwareMessage for details on the message sent/received to this port number
  case remoteHardwareApp // = 2

  ///
  /// The built-in position messaging app.
  /// See Position for details on the message sent to this port number.
  case positionApp // = 3

  ///
  /// The built-in user info app.
  /// See User for details on the message sent to this port number.
  case nodeinfoApp // = 4

  ///
  /// Provides a 'ping' service that replies to any packet it receives.  Also this serves as a small example plugin.
  case replyApp // = 32

  ///
  /// Used for the python IP tunnel feature
  case ipTunnelApp // = 33

  ///
  /// Provides a hardware serial interface to send and receive from the Meshtastic network.
  /// Connect to the RX/TX pins of a device with 38400 8N1. Packets received from the Meshtastic
  /// network is forwarded to the RX pin while sending a packet to TX will go out to the Mesh
  /// network. Maximum packet size of 240 bytes.
  ///
  /// Maintained by Jm Casler (MC Hamster) : jm@casler.org
  case serialApp // = 64

  ///
  /// STORE_REQUEST_APP (Work in Progress)
  ///
  /// Maintained by Jm Casler (MC Hamster) : jm@casler.org
  case storeRequestApp // = 65

  ///
  /// Private applications should use portnums >= 256.
  /// To simplify initial development and testing you can use "PRIVATE_APP"
  /// in your code without needing to rebuild protobuf files (via bin/regin_protos.sh)
  case privateApp // = 256

  ///
  /// ATAK Forwarder Plugin https://github.com/paulmandal/atak-forwarder
  case atakForwarder // = 257
  case UNRECOGNIZED(Int)

  init() {
    self = .unknownApp
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .unknownApp
    case 1: self = .textMessageApp
    case 2: self = .remoteHardwareApp
    case 3: self = .positionApp
    case 4: self = .nodeinfoApp
    case 32: self = .replyApp
    case 33: self = .ipTunnelApp
    case 64: self = .serialApp
    case 65: self = .storeRequestApp
    case 256: self = .privateApp
    case 257: self = .atakForwarder
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .unknownApp: return 0
    case .textMessageApp: return 1
    case .remoteHardwareApp: return 2
    case .positionApp: return 3
    case .nodeinfoApp: return 4
    case .replyApp: return 32
    case .ipTunnelApp: return 33
    case .serialApp: return 64
    case .storeRequestApp: return 65
    case .privateApp: return 256
    case .atakForwarder: return 257
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension PortNum: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [PortNum] = [
    .unknownApp,
    .textMessageApp,
    .remoteHardwareApp,
    .positionApp,
    .nodeinfoApp,
    .replyApp,
    .ipTunnelApp,
    .serialApp,
    .storeRequestApp,
    .privateApp,
    .atakForwarder,
  ]
}

#endif  // swift(>=4.2)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension PortNum: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "UNKNOWN_APP"),
    1: .same(proto: "TEXT_MESSAGE_APP"),
    2: .same(proto: "REMOTE_HARDWARE_APP"),
    3: .same(proto: "POSITION_APP"),
    4: .same(proto: "NODEINFO_APP"),
    32: .same(proto: "REPLY_APP"),
    33: .same(proto: "IP_TUNNEL_APP"),
    64: .same(proto: "SERIAL_APP"),
    65: .same(proto: "STORE_REQUEST_APP"),
    256: .same(proto: "PRIVATE_APP"),
    257: .same(proto: "ATAK_FORWARDER"),
  ]
}