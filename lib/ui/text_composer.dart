import 'dart:io';

import 'package:chat_pdm/helpers/firebase_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  TextEditingController controller = TextEditingController();
  FireBaseHelper helper = FireBaseHelper();
  bool _isComposing = false;
  bool _isSendImage = false;

  void _reset() {
    controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(
        children: [
          _isSendImage ? LinearProgressIndicator() : Container(),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.photo_camera),
                onPressed: () async {
                  PickedFile pfile = await ImagePicker.platform
                      .pickImage(source: ImageSource.camera);
                  if (pfile != null) {
                    File file = File(pfile.path);
                    setState(() {
                      _isSendImage = true;
                    });
                    helper.sendImage(file).then((value) {
                      setState(() {
                        _isSendImage = false;
                      });
                    });
                  }
                },
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration.collapsed(
                      hintText: "Enviar uma mensagem"),
                  onChanged: (text) {
                    setState(() {
                      _isComposing = text.isNotEmpty;
                    });
                  },
                  onSubmitted: (text) {
                    helper.sendMessage(text);
                    _reset();
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _isComposing
                    ? () {
                        helper.sendMessage(controller.text);
                        _reset();
                      }
                    : null,
              )
            ],
          )
        ],
      ),
    );
  }
}
