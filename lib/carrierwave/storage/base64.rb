# encoding: utf-8
require 'base64'

module CarrierWave
  module Storage
    class Base64 < Abstract

      class File
        def initialize(uploader)
          @uploader = uploader
        end

        def path
          nil
        end

        def read
          d = self.data[:data]
          d ? ::Base64.decode64(d) : nil
        end

        def delete
          # TODO clear the field?
        end

        def url
          d = self.data[:data]
          d ? "data:#{self.data[:content_type] || 'image/png'};base64,#{d}" : nil
        end

        def store(file)
          self.data = {
            :data => "#{::Base64.encode64(file.read)}",
            :content_type => file.content_type }
        end
        
        def content_type
          self.data[:content_type]
        end
           
        def data=(v)
          m, f = @uploader.model, @uploader.mounted_as
          updated = m.send("#{f}_data") != v
          if updated
            m.send("#{f}_data=", v)
            m.save
          end
        end
        
        def data
          @uploader.model.send("#{@uploader.mounted_as}_data") || {}
        end
      end

      def store!(file)
        f = CarrierWave::Storage::Base64::File.new(uploader)
        f.store(file)
        f
      end

      def retrieve!(identifier)
        CarrierWave::Storage::Base64::File.new(uploader)
      end

    end # S3
  end # Storage
end # CarrierWave

