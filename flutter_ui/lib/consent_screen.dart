import 'package:flutter/material.dart';
import 'main.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _consentGiven = false;

  void _proceedToLogin() {
    if (_consentGiven) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a1a),
              Color(0xFF2d2d2d),
              Color(0xFF1a1a1a),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600), 
              child: Card(
                elevation: 20,
                shadowColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Colors.lightBlueAccent,
                    width: 1,
                  ),
                ),
                color: const Color(0xFF2a2a2a),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.lightBlueAccent,
                            Colors.lightBlue.shade300,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'Consent for User Testing',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please read and accept to continue',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                     
                      Container(
                        height: 300, 
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1a1a1a),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.lightBlueAccent,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            _getConsentText(), 
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.lightBlueAccent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF1a1a1a),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _consentGiven 
                                      ? Colors.lightBlueAccent
                                      : Colors.grey.shade600,
                                  width: 2,
                                ),
                              ),
                              child: Checkbox(
                                value: _consentGiven,
                                onChanged: (value) {
                                  setState(() {
                                    _consentGiven = value ?? false;
                                  });
                                },
                                activeColor: Colors.lightBlueAccent,
                                checkColor: Colors.white,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'I have read and agree to the consent details above',
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Continue button - same style as login
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _consentGiven
                                  ? [Colors.blue, Colors.lightBlueAccent]
                                  : [Colors.grey.shade700, Colors.grey.shade800],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _consentGiven ? [
                              BoxShadow(
                                color: Colors.lightBlue,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ] : [],
                          ),
                          child: ElevatedButton(
                            onPressed: _consentGiven ? _proceedToLogin : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Continue to SynthApp',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _consentGiven ? Colors.white : Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.lightBlueAccent,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getConsentText() {
    return '''
    Name of department: Computer and Information Sciences 
    Title of the study: Development of a Cross-Platform Software Synthesizer for Native Desktop and Mobile Devices

    - I confirm that I have read and understood the Participant Information Sheet for the above project and the 
      researcher has answered any queries to my satisfaction.
    - I confirm that I have read and understood the Privacy Notice for Participants in Research Projects and understand how my personal information will be used and what will happen to it (i.e. how it will be stored and for how long).
    - I understand that my participation is voluntary and that I am free to withdraw from the project at any time, up to the point of completion, without having to give a reason and without any consequences.
    - I understand that anonymised data (i.e. data that do not identify me personally) cannot be withdrawn once they have been included in the study.
    - I understand that any information recorded in the research will remain confidential and no information that identifies me will be made publicly available.
    - I consent to being a participant in the project.
    ''';
  }
}