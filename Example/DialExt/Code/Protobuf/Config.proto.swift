/// Generated by the Protocol Buffers 3.3.2 compiler.  DO NOT EDIT!
/// Protobuf-swift version: 3.0.22
/// Source file "config.proto"
/// Syntax "Proto3"

import Foundation
import ProtocolBuffers


public struct ConfigRoot {
    public static let `default` = ConfigRoot()
    public var extensionRegistry:ExtensionRegistry

    init() {
        extensionRegistry = ExtensionRegistry()
        registerAllExtensions(registry: extensionRegistry)
    }
    public func registerAllExtensions(registry: ExtensionRegistry) {
    }
}

final public class MessengerConfig : GeneratedMessage {
    public typealias BuilderType = MessengerConfig.Builder

    public static func == (lhs: MessengerConfig, rhs: MessengerConfig) -> Bool {
        if lhs === rhs {
            return true
        }
        var fieldCheck:Bool = (lhs.hashValue == rhs.hashValue)
        fieldCheck = fieldCheck && (lhs.hasSharingEndpoint == rhs.hasSharingEndpoint) && (!lhs.hasSharingEndpoint || lhs.sharingEndpoint == rhs.sharingEndpoint)
        fieldCheck = (fieldCheck && (lhs.unknownFields == rhs.unknownFields))
        return fieldCheck
    }

    public fileprivate(set) var sharingEndpoint:String! = nil
    public fileprivate(set) var hasSharingEndpoint:Bool = false

    required public init() {
        super.init()
    }
    override public func isInitialized() -> Bool {
        return true
    }
    override public func writeTo(codedOutputStream: CodedOutputStream) throws {
        if hasSharingEndpoint {
            try codedOutputStream.writeString(fieldNumber: 1, value:sharingEndpoint)
        }
        try unknownFields.writeTo(codedOutputStream: codedOutputStream)
    }
    override public func serializedSize() -> Int32 {
        var serialize_size:Int32 = memoizedSerializedSize
        if serialize_size != -1 {
         return serialize_size
        }

        serialize_size = 0
        if hasSharingEndpoint {
            serialize_size += sharingEndpoint.computeStringSize(fieldNumber: 1)
        }
        serialize_size += unknownFields.serializedSize()
        memoizedSerializedSize = serialize_size
        return serialize_size
    }
    public class func getBuilder() -> MessengerConfig.Builder {
        return MessengerConfig.classBuilder() as! MessengerConfig.Builder
    }
    public func getBuilder() -> MessengerConfig.Builder {
        return classBuilder() as! MessengerConfig.Builder
    }
    override public class func classBuilder() -> ProtocolBuffersMessageBuilder {
        return MessengerConfig.Builder()
    }
    override public func classBuilder() -> ProtocolBuffersMessageBuilder {
        return MessengerConfig.Builder()
    }
    public func toBuilder() throws -> MessengerConfig.Builder {
        return try MessengerConfig.builderWithPrototype(prototype:self)
    }
    public class func builderWithPrototype(prototype:MessengerConfig) throws -> MessengerConfig.Builder {
        return try MessengerConfig.Builder().mergeFrom(other:prototype)
    }
    override public func encode() throws -> Dictionary<String,Any> {
        guard isInitialized() else {
            throw ProtocolBuffersError.invalidProtocolBuffer("Uninitialized Message")
        }

        var jsonMap:Dictionary<String,Any> = Dictionary<String,Any>()
        if hasSharingEndpoint {
            jsonMap["sharingEndpoint"] = sharingEndpoint
        }
        return jsonMap
    }
    override class public func decode(jsonMap:Dictionary<String,Any>) throws -> MessengerConfig {
        return try MessengerConfig.Builder.decodeToBuilder(jsonMap:jsonMap).build()
    }
    override class public func fromJSON(data:Data) throws -> MessengerConfig {
        return try MessengerConfig.Builder.fromJSONToBuilder(data:data).build()
    }
    override public func getDescription(indent:String) throws -> String {
        var output = ""
        if hasSharingEndpoint {
            output += "\(indent) sharingEndpoint: \(sharingEndpoint) \n"
        }
        output += unknownFields.getDescription(indent: indent)
        return output
    }
    override public var hashValue:Int {
        get {
            var hashCode:Int = 7
            if hasSharingEndpoint {
                hashCode = (hashCode &* 31) &+ sharingEndpoint.hashValue
            }
            hashCode = (hashCode &* 31) &+  unknownFields.hashValue
            return hashCode
        }
    }


    //Meta information declaration start

    override public class func className() -> String {
        return "MessengerConfig"
    }
    override public func className() -> String {
        return "MessengerConfig"
    }
    //Meta information declaration end

    final public class Builder : GeneratedMessageBuilder {
        fileprivate var builderResult:MessengerConfig = MessengerConfig()
        public func getMessage() -> MessengerConfig {
            return builderResult
        }

        required override public init () {
            super.init()
        }
        public var sharingEndpoint:String {
            get {
                return builderResult.sharingEndpoint
            }
            set (value) {
                builderResult.hasSharingEndpoint = true
                builderResult.sharingEndpoint = value
            }
        }
        public var hasSharingEndpoint:Bool {
            get {
                return builderResult.hasSharingEndpoint
            }
        }
        @discardableResult
        public func setSharingEndpoint(_ value:String) -> MessengerConfig.Builder {
            self.sharingEndpoint = value
            return self
        }
        @discardableResult
        public func clearSharingEndpoint() -> MessengerConfig.Builder{
            builderResult.hasSharingEndpoint = false
            builderResult.sharingEndpoint = nil
            return self
        }
        override public var internalGetResult:GeneratedMessage {
            get {
                return builderResult
            }
        }
        @discardableResult
        override public func clear() -> MessengerConfig.Builder {
            builderResult = MessengerConfig()
            return self
        }
        override public func clone() throws -> MessengerConfig.Builder {
            return try MessengerConfig.builderWithPrototype(prototype:builderResult)
        }
        override public func build() throws -> MessengerConfig {
            try checkInitialized()
            return buildPartial()
        }
        public func buildPartial() -> MessengerConfig {
            let returnMe:MessengerConfig = builderResult
            return returnMe
        }
        @discardableResult
        public func mergeFrom(other:MessengerConfig) throws -> MessengerConfig.Builder {
            if other == MessengerConfig() {
                return self
            }
            if other.hasSharingEndpoint {
                sharingEndpoint = other.sharingEndpoint
            }
            try merge(unknownField: other.unknownFields)
            return self
        }
        @discardableResult
        override public func mergeFrom(codedInputStream: CodedInputStream) throws -> MessengerConfig.Builder {
            return try mergeFrom(codedInputStream: codedInputStream, extensionRegistry:ExtensionRegistry())
        }
        @discardableResult
        override public func mergeFrom(codedInputStream: CodedInputStream, extensionRegistry:ExtensionRegistry) throws -> MessengerConfig.Builder {
            let unknownFieldsBuilder:UnknownFieldSet.Builder = try UnknownFieldSet.builderWithUnknownFields(copyFrom:self.unknownFields)
            while (true) {
                let protobufTag = try codedInputStream.readTag()
                switch protobufTag {
                case 0: 
                    self.unknownFields = try unknownFieldsBuilder.build()
                    return self

                case 10:
                    sharingEndpoint = try codedInputStream.readString()

                default:
                    if (!(try parse(codedInputStream:codedInputStream, unknownFields:unknownFieldsBuilder, extensionRegistry:extensionRegistry, tag:protobufTag))) {
                        unknownFields = try unknownFieldsBuilder.build()
                        return self
                    }
                }
            }
        }
        class override public func decodeToBuilder(jsonMap:Dictionary<String,Any>) throws -> MessengerConfig.Builder {
            let resultDecodedBuilder = MessengerConfig.Builder()
            if let jsonValueSharingEndpoint = jsonMap["sharingEndpoint"] as? String {
                resultDecodedBuilder.sharingEndpoint = jsonValueSharingEndpoint
            }
            return resultDecodedBuilder
        }
        override class public func fromJSONToBuilder(data:Data) throws -> MessengerConfig.Builder {
            let jsonData = try JSONSerialization.jsonObject(with:data, options: JSONSerialization.ReadingOptions(rawValue: 0))
            guard let jsDataCast = jsonData as? Dictionary<String,Any> else {
              throw ProtocolBuffersError.invalidProtocolBuffer("Invalid JSON data")
            }
            return try MessengerConfig.Builder.decodeToBuilder(jsonMap:jsDataCast)
        }
    }

}

extension MessengerConfig: GeneratedMessageProtocol {
    public class func parseArrayDelimitedFrom(inputStream: InputStream) throws -> Array<MessengerConfig> {
        var mergedArray = Array<MessengerConfig>()
        while let value = try parseDelimitedFrom(inputStream: inputStream) {
          mergedArray.append(value)
        }
        return mergedArray
    }
    public class func parseDelimitedFrom(inputStream: InputStream) throws -> MessengerConfig? {
        return try MessengerConfig.Builder().mergeDelimitedFrom(inputStream: inputStream)?.build()
    }
    public class func parseFrom(data: Data) throws -> MessengerConfig {
        return try MessengerConfig.Builder().mergeFrom(data: data, extensionRegistry:ConfigRoot.default.extensionRegistry).build()
    }
    public class func parseFrom(data: Data, extensionRegistry:ExtensionRegistry) throws -> MessengerConfig {
        return try MessengerConfig.Builder().mergeFrom(data: data, extensionRegistry:extensionRegistry).build()
    }
    public class func parseFrom(inputStream: InputStream) throws -> MessengerConfig {
        return try MessengerConfig.Builder().mergeFrom(inputStream: inputStream).build()
    }
    public class func parseFrom(inputStream: InputStream, extensionRegistry:ExtensionRegistry) throws -> MessengerConfig {
        return try MessengerConfig.Builder().mergeFrom(inputStream: inputStream, extensionRegistry:extensionRegistry).build()
    }
    public class func parseFrom(codedInputStream: CodedInputStream) throws -> MessengerConfig {
        return try MessengerConfig.Builder().mergeFrom(codedInputStream: codedInputStream).build()
    }
    public class func parseFrom(codedInputStream: CodedInputStream, extensionRegistry:ExtensionRegistry) throws -> MessengerConfig {
        return try MessengerConfig.Builder().mergeFrom(codedInputStream: codedInputStream, extensionRegistry:extensionRegistry).build()
    }
    public subscript(key: String) -> Any? {
        switch key {
        case "sharingEndpoint": return self.sharingEndpoint
        default: return nil
        }
    }
}
extension MessengerConfig.Builder: GeneratedMessageBuilderProtocol {
    public typealias GeneratedMessageType = MessengerConfig
    public subscript(key: String) -> Any? {
        get { 
            switch key {
            case "sharingEndpoint": return self.sharingEndpoint
            default: return nil
            }
        }
        set (newSubscriptValue) { 
            switch key {
            case "sharingEndpoint":
                guard let newSubscriptValue = newSubscriptValue as? String else {
                    return
                }
                self.sharingEndpoint = newSubscriptValue
            default: return
            }
        }
    }
}

// @@protoc_insertion_point(global_scope)
