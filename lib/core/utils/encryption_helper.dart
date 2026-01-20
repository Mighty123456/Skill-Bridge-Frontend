import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  // Hardcoded key for demonstration (32 chars for AES-256)
  // In a real app, this should be derived or exchanged securely.
  static final _key = encrypt.Key.fromUtf8('SkillBridgeSecureChatKey2026!!!!'); 
  // Fixed IV (Initialization Vector) for demo; usually distinct per message but requires storage.
  static final _iv = encrypt.IV.fromUtf8('FixedIV16Bytes!!');

  static String encryptMessage(String plainText) {
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final encrypted = encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      return plainText; // Fallback? Or throw.
    }
  }

  static String decryptMessage(String encryptedText) {
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      return encrypter.decrypt(encrypt.Encrypted.fromBase64(encryptedText), iv: _iv);
    } catch (e) {
      // If decryption fails (maybe it wasn't encrypted or key mismatch), return original
      return encryptedText;
    }
  }
}
