import 'package:flutter/material.dart';
import 'alert_service.dart';
import 'auth_service.dart';
import 'navigation_service.dart';

class DeleteAccountDialog extends StatefulWidget {
  final AuthService authService;
  final NavigationService navigationService;
  final AlertService alertService;

  const DeleteAccountDialog({
    Key? key,
    required this.authService,
    required this.navigationService,
    required this.alertService,
  }) : super(key: key);

  static Future<void> show(
      BuildContext context, {
        required AuthService authService,
        required NavigationService navigationService,
        required AlertService alertService,
      }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => DeleteAccountDialog(
        authService: authService,
        navigationService: navigationService,
        alertService: alertService,
      ),
    );
  }

  @override
  _DeleteAccountDialogState createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        bool success = await widget.authService.deleteUser(
            _passwordController.text.trim()
        );

        if (success) {
          Navigator.of(context).pop();

          widget.navigationService.pushReplacementNamed('/login');
        } else {
          widget.alertService.showToast(
            text: 'Fout bij verwijderen account. Controleer uw wachtwoord.',
            icon: Icons.error_outline,
          );
        }
      } catch (e) {
        widget.alertService.showToast(
          text: 'Fout bij verwijderen account.',
          icon: Icons.error_outline,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Account verwijderen'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Voer uw wachtwoord in om uw account permanent te verwijderen.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Wachtwoord',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Voer uw wachtwoord in';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Annuleren'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _isLoading ? null : _deleteAccount,
          child: _isLoading
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              )
          )
              : const Text('Verwijderen'),
        ),
      ],
    );
  }
}