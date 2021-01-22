# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class Metadata
        attr_reader :schema_major_version, :schema_minor_version

        def initialize(schema_major_version, schema_minor_version)
          @schema_major_version = schema_major_version
          @schema_minor_version = schema_minor_version
        end

        class << self
          def create_from_json(metadata_json)
            metadata_hash = JSON.parse(metadata_json)
            schema_versions = metadata_hash["schemaVersions"]
            if schema_versions.nil?
              err_msg = "Metadata is missing schemaVersions"
              raise ::Script::Layers::Domain::Errors::MetadataValidationError, err_msg
            end
            # Scripts may be attached to more than one EP in the future but not right now
            unless schema_versions.count == 1
              err_msg = "Metadata schemaVersions should have one key"
              raise ::Script::Layers::Domain::Errors::MetadataValidationError, err_msg
            end

            _, version = schema_versions.first
            schema_major_version = version["major"]
            schema_minor_version = version["minor"]
            if schema_major_version.nil?
              err_msg = "Metadata schema version is missing major key"
              raise ::Script::Layers::Domain::Errors::MetadataValidationError, err_msg
            end
            is_prerelease = schema_major_version == "prerelease"

            if schema_minor_version.nil? && !is_prerelease
              err_msg = "Metadata schema version is missing minor key"
              raise ::Script::Layers::Domain::Errors::MetadataValidationError, err_msg
            end

            Metadata.new(schema_major_version, schema_minor_version)
          end
        end
      end
    end
  end
end
