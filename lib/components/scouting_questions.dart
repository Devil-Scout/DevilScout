import 'package:flutter/material.dart';

import '../supabase/database.dart';
import '../supabase/scouting/questions.dart';
import '../supabase/scouting/scouting.dart';

class SubmissionData with ChangeNotifier {
  final Map<Uuid, dynamic> _data = {};
  final Map<Uuid, Question> _questions;
  final Set<Uuid> _invalidResponses;

  bool get isValid => _invalidResponses.isEmpty;

  SubmissionData({required Map<Uuid, Question> questions})
      : _questions = questions,
        _invalidResponses = questions.keys.toSet();

  Map<String, dynamic> toJson() => Map.unmodifiable(_data);

  dynamic operator [](Uuid questionId) => _data[questionId];

  void operator []=(Uuid questionId, dynamic value) {
    final question = _questions[questionId]!;
    final isValueValid = question.config.validate(question.dataType, value);
    if (isValueValid) {
      _invalidResponses.remove(questionId);
    } else {
      _invalidResponses.add(questionId);
    }

    _data[questionId] = value;
    notifyListeners();
  }
}

class ResponseData<T> with ChangeNotifier {
  final Uuid _questionId;
  final SubmissionData _data;

  ResponseData({
    required SubmissionData data,
    required String questionId,
  })  : _questionId = questionId,
        _data = data;

  bool get hasValue => _data[_questionId] != null;
  T get value => _data[_questionId] as T;
  set value(T value) {
    _data[_questionId] = value;
    notifyListeners();
  }
}

class QuestionView extends StatelessWidget {
  final Question question;
  final SubmissionData data;

  const QuestionView({
    super.key,
    required this.question,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(question.prompt),
        _questionWidget(),
      ],
    );
  }

  Widget _questionWidget() =>
      switch ((question.dataType, question.config.style)) {
        (DataType.boolean, QuestionStyle.segmented) => YesNoQuestion(
            config: question.config,
            response: ResponseData(data: data, questionId: question.id),
          ),
        (DataType.boolean, QuestionStyle.checkbox) => CheckboxQuestion(
            config: question.config,
            response: ResponseData(data: data, questionId: question.id),
          ),
        (DataType.number, QuestionStyle.textField) => NumberQuestion(
            config: question.config,
            response: ResponseData(data: data, questionId: question.id),
          ),
        (DataType.number, QuestionStyle.counter) => CounterQuestion(
            config: question.config,
            response: ResponseData(data: data, questionId: question.id),
          ),
        (DataType.string, QuestionStyle.dropdown) => DropdownQuestion(
            config: question.config,
            response: ResponseData(data: data, questionId: question.id),
          ),
        (DataType.string, QuestionStyle.radio) => RadioQuestion(
            config: question.config,
            response: ResponseData(data: data, questionId: question.id),
          ),
        (DataType.stringArray, QuestionStyle.checkbox) => MultiSelectQuestion(
            config: question.config,
            response: ResponseData(data: data, questionId: question.id),
          ),
        _ => throw UnimplementedError(),
      };
}

class YesNoQuestion extends StatelessWidget {
  final BooleanConfig config;
  final ResponseData<bool> response;

  const YesNoQuestion({
    super.key,
    required this.config,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: true, label: Text('Yes')),
        ButtonSegment(value: false, label: Text('No')),
      ],
      selected: response.hasValue ? {} : {response.value},
      emptySelectionAllowed: true,
      onSelectionChanged: (newValue) => response.value = newValue.single,
    );
  }
}

class CheckboxQuestion extends StatelessWidget {
  final BooleanConfig config;
  final ResponseData<bool> response;

  CheckboxQuestion({
    super.key,
    required this.config,
    required this.response,
  }) {
    response.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: response,
      builder: (context, child) {
        return Checkbox(
          value: response.value,
          onChanged: (newValue) => response.value = newValue!,
        );
      },
    );
  }
}

class CounterQuestion extends StatelessWidget {
  final NumberConfig config;
  final ResponseData<int> response;

  CounterQuestion({
    super.key,
    required this.config,
    required this.response,
  }) {
    response.value = config.min?.toInt() ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: response,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _canDecrement()
                  ? () => response.value = response.value - 1
                  : null,
              icon: const Icon(Icons.remove),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 40),
              child: Text(
                response.value.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            IconButton(
              onPressed: _canIncrement()
                  ? () => response.value = response.value + 1
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        );
      },
    );
  }

  bool _canIncrement() {
    final max = config.max;
    return max == null || response.value < max;
  }

  bool _canDecrement() {
    final min = config.min;
    return min == null || response.value > min;
  }
}

class DropdownQuestion extends StatelessWidget {
  final StringConfig config;
  final ResponseData<String> response;

  const DropdownQuestion({
    super.key,
    required this.config,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      dropdownMenuEntries: config.options!
          .map((option) => DropdownMenuEntry(value: option, label: option))
          .toList(),
      onSelected: (value) => response.value = value ?? response.value,
    );
  }
}

class RadioQuestion extends StatelessWidget {
  final StringConfig config;
  final ResponseData<String> response;

  const RadioQuestion({
    super.key,
    required this.config,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: response,
      builder: (context, child) {
        return Column(
          children: config.options!
              .map(
                (option) => RadioListTile(
                  value: option,
                  groupValue: response.value,
                  onChanged: (newValue) => response.value = newValue!,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class MultiSelectQuestion extends StatelessWidget {
  final ArrayConfig config;
  final ResponseData<Set<String>> response;

  const MultiSelectQuestion({
    super.key,
    required this.config,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: config.options!
            .map(
              (option) => CheckboxListTile(
                value: response.value.contains(option),
                dense: true,
                title: Text(
                  option,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                onChanged: (b) => b!
                    ? response.value.remove(option)
                    : response.value.add(option),
              ),
            )
            .toList(),
      ),
    );
  }
}

class NumberQuestion extends StatelessWidget {
  final NumberConfig config;
  final ResponseData<num> response;

  const NumberQuestion({
    super.key,
    required this.config,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: _inputType(),
      onChanged: (str) => response.value = num.parse(str),
    );
  }

  TextInputType _inputType() {
    final min = config.min;
    final step = config.step;
    return TextInputType.numberWithOptions(
      signed: min == null || min is int,
      decimal: step == null || step.toInt() == step,
    );
  }
}
