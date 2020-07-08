require "base64"
require "openssl"
require "digest/sha1"

class Cipher
  def self.encrypt(text)
    cipher = OpenSSL::Cipher.new("aes-256-cbc")
    cipher.encrypt
    key = Digest::SHA1.hexdigest("yourpass")[0..31]
    iv = cipher.random_iv
    cipher.key = key
    cipher.iv = iv
    encrypted = cipher.update(text)
    encrypted << cipher.final
    ["#{key}:#{Base64.encode64(iv).encode("utf-8")}", Base64.encode64(encrypted).encode("utf-8")]
  end

  def self.decrypt(encrypted, salt)
    key, iv = salt.split(":")
    iv = Base64.decode64(iv.encode("ascii-8bit"))
    cipher = OpenSSL::Cipher.new("aes-256-cbc")
    cipher.decrypt
    cipher.key = key
    cipher.iv = iv
    decrypted = cipher.update(Base64.decode64(encrypted.encode("ascii-8bit")))
    decrypted << cipher.final
    decrypted
  end
end
