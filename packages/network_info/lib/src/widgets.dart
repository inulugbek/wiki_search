import 'package:flutter/material.dart';

import 'network_info.dart';

class NetworkInfoStatus extends StatelessWidget {
  final Widget child;
  final String noNetworkMessage;

  const NetworkInfoStatus({
    @required this.child,
    @required this.noNetworkMessage,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        child: StreamBuilder<bool>(
          initialData: true,
          stream: NetworkInfo().isConnectedStream,
          builder: (context, snapshot) {
            final isConnected = snapshot.data;

            return Stack(
              fit: StackFit.expand,
              children: [
                // content
                child,

                // info message
                if (!isConnected)
                  Positioned(
                    bottom: MediaQuery.of(context).viewPadding.bottom + 80.0,
                    left: 20,
                    right: 20,
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Text(
                            noNetworkMessage,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            );
          },
        ),
      );
}
