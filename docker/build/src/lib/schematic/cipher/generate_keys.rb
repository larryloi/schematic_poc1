# frozen-string-literal: true

module Schematic
  class Cipher
    def generate_keys
      rsa_key = OpenSSL::PKey::RSA.generate key_length

      print "Saving private Key (#{private_key_file}) ... "
      File.write(private_key_file, rsa_key.to_pem)
      puts 'done'

      print "Saving public key (#{public_key_file}) ..."
      File.write(public_key_file, rsa_key.public_to_pem)
      puts 'done'
    end
  end
end
