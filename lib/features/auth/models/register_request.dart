
class RegisterRequest {
  final String nombre;
  final String username;
  final String email;
  final String password;

  const RegisterRequest({
    required this.nombre,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre.trim(),
        'username': username.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      };
}
