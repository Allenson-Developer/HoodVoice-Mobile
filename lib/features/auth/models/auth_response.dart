
class AuthResponse {
  final String id;
  final String token;
  final String username;
  final String nombre;
  final String role;
  final String estado;

  const AuthResponse({
    required this.id,
    required this.token,
    required this.username,
    required this.nombre,
    this.role = 'USER',
    this.estado = 'ACTIVO',
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      token: (json['token'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      role: (json['role'] ?? 'USER').toString(),
      estado: (json['estado'] ?? 'ACTIVO').toString(),
    );
  }
}
