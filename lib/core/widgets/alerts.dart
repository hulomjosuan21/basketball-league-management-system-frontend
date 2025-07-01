import 'package:flutter/material.dart';

Widget buildInfoAlert(String message, VoidCallback onDismiss) {
  return _buildCompactAlert(
    message: message,
    color: Colors.blue[50]!,
    textColor: Colors.blue[800]!,
    icon: Icons.info,
    iconColor: Colors.blue,
    onDismiss: onDismiss,
  );
}

Widget buildWarningAlert(String message, VoidCallback onDismiss) {
  return _buildCompactAlert(
    message: message,
    color: Colors.amber[100]!,
    textColor: Colors.orange[900]!,
    icon: Icons.warning,
    iconColor: Colors.orange,
    onDismiss: onDismiss,
  );
}

Widget buildSuccessAlert(String message, VoidCallback onDismiss) {
  return _buildCompactAlert(
    message: message,
    color: Colors.green[100]!,
    textColor: Colors.green[900]!,
    icon: Icons.check_circle,
    iconColor: Colors.green,
    onDismiss: onDismiss,
  );
}

Widget buildErrorAlert(String message, VoidCallback onDismiss) {
  return _buildCompactAlert(
    message: message,
    color: Colors.red[100]!,
    textColor: Colors.red[900]!,
    icon: Icons.error,
    iconColor: Colors.red,
    onDismiss: onDismiss,
  );
}

Widget _buildCompactAlert({
  required String message,
  required Color color,
  required Color textColor,
  required IconData icon,
  required Color iconColor,
  required VoidCallback onDismiss,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: iconColor),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(fontSize: 13, color: textColor),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: onDismiss,
          child: Text("DISMISS", style: TextStyle(fontSize: 12)),
        ),
      ],
    ),
  );
}
