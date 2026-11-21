import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';
import 'demo_chat.dart';

const _leo = ChatUser(id: 'leo', name: 'Leo');
const _sam = ChatUser(id: 'sam', name: 'Sam');
const _shop = ChatUser(id: 'shop', name: 'Corner Shop', isBot: true);

final contentFeatures = FeatureGroup('Rich content', [
  FeatureDemo(
    title: 'Polls',
    description: 'Quick questions with single or multiple answers.',
    icon: Icons.poll_outlined,
    builder: (_) => DemoChat(
      title: 'Polls',
      hint: 'Tap an option to vote; tap it again to remove your vote. The '
          'second poll accepts several answers.',
      seed: () => [
        PollMessage(
          id: 'p1',
          author: ana,
          createdAt: ago(6),
          question: 'Where do we go for lunch?',
          options: const [
            PollOption(id: 'pizza', text: 'Pizza', voterIds: ['ana', 'leo']),
            PollOption(id: 'sushi', text: 'Sushi', voterIds: ['sam']),
            PollOption(id: 'tacos', text: 'Tacos'),
          ],
        ),
        PollMessage(
          id: 'p2',
          author: _leo,
          createdAt: ago(3),
          question: 'Which days work for the offsite?',
          allowsMultipleAnswers: true,
          options: const [
            PollOption(id: 'mon', text: 'Monday', voterIds: ['leo']),
            PollOption(id: 'wed', text: 'Wednesday', voterIds: ['ana']),
            PollOption(id: 'fri', text: 'Friday', voterIds: ['leo', 'sam']),
          ],
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        contentCallbacks: ChatContentCallbacks(
          onPollVote: (poll, optionId) => c.votePoll(poll.id, optionId, me.id),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Surveys',
    description: 'Questionnaires with choices, ratings, NPS and text.',
    icon: Icons.assignment_outlined,
    builder: (_) => DemoChat(
      title: 'Surveys',
      hint: 'Open the survey, answer the questions and submit.',
      seed: () => [
        text('v0', 'We would love your feedback 🙏', author: bot),
        SurveyMessage(
          id: 'v1',
          author: bot,
          createdAt: ago(4),
          title: 'How was your order?',
          description: 'Four quick questions, under a minute.',
          respondentIds: const ['ana'],
          questions: const [
            ChoiceQuestion(
              id: 'channel',
              title: 'How did you order?',
              choices: [
                SurveyChoice(id: 'app', text: 'Mobile app'),
                SurveyChoice(id: 'web', text: 'Website'),
                SurveyChoice(id: 'store', text: 'In store'),
              ],
            ),
            RatingQuestion(id: 'delivery', title: 'Rate the delivery'),
            NpsQuestion(
              id: 'nps',
              title: 'How likely are you to recommend us?',
            ),
            TextQuestion(
              id: 'comment',
              title: 'Anything else?',
              hint: 'Tell us more',
              maxLength: 200,
              isRequired: false,
            ),
          ],
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        contentCallbacks: ChatContentCallbacks(
          onSurveySubmit: (survey, response) {
            c.recordSurveyResponse(survey.id, me.id);
            toast(
              context,
              'Survey sent with ${response.answers.length} answers',
            );
          },
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Countdown',
    description: 'An announcement that counts down to a moment.',
    icon: Icons.hourglass_bottom,
    builder: (_) => DemoChat(
      title: 'Countdown',
      hint: 'The timer ticks live and shows the done label after two '
          'minutes.',
      seed: () => [
        CountdownMessage(
          id: 'c1',
          author: ana,
          createdAt: ago(1),
          title: 'Doors open',
          description: 'The launch stream starts soon.',
          endsAt: DateTime.now().add(const Duration(minutes: 2)),
          completedLabel: 'We are live!',
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Events and RSVP',
    description: 'Event cards where everyone answers going, maybe or no.',
    icon: Icons.event_outlined,
    builder: (_) => DemoChat(
      title: 'Events',
      hint: 'Tap Going, Maybe or No; the counts update. Tap again to '
          'change your answer.',
      seed: () => [
        EventMessage(
          id: 'ev1',
          author: ana,
          createdAt: ago(10),
          title: 'Team dinner',
          startsAt: DateTime.now().add(const Duration(days: 2, hours: 3)),
          endsAt: DateTime.now().add(const Duration(days: 2, hours: 6)),
          location: 'La Taberna, Main St 12',
          description: 'Celebrating the 0.2.0 release.',
          rsvps: const {
            'ana': ChatRsvp.going,
            'leo': ChatRsvp.maybe,
            'sam': ChatRsvp.notGoing,
          },
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        contentCallbacks: ChatContentCallbacks(
          onRsvp: (event, rsvp) => c.setRsvp(event.id, me.id, rsvp),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Checklists',
    description: 'Shared to-do lists anyone can tick.',
    icon: Icons.checklist_rtl,
    builder: (_) => DemoChat(
      title: 'Checklists',
      hint: 'Tap an item to check or uncheck it.',
      seed: () => [
        ChecklistMessage(
          id: 'k1',
          author: _leo,
          createdAt: ago(5),
          title: 'Release 0.3.0',
          items: const [
            ChecklistItem(id: 'a', text: 'Update the changelog', doneBy: 'leo'),
            ChecklistItem(id: 'b', text: 'Run the golden tests'),
            ChecklistItem(id: 'c', text: 'Record new screenshots'),
            ChecklistItem(id: 'd', text: 'Publish to pub.dev'),
          ],
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        contentCallbacks: ChatContentCallbacks(
          onChecklistToggle: (list, item) =>
              c.toggleChecklistItem(list.id, item.id, me.id),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Products',
    description: 'A product card and a swipeable carousel.',
    icon: Icons.shopping_bag_outlined,
    builder: (_) => DemoChat(
      title: 'Products',
      hint: 'Tap a product button. Swipe the carousel sideways.',
      seed: () => [
        ProductMessage(
          id: 'pr1',
          author: _shop,
          createdAt: ago(6),
          text: 'Your gift card is ready:',
          products: const [
            ChatProduct(
              id: 'card',
              title: 'Gift card',
              subtitle: 'Valid for one year',
              price: r'$25.00',
              imageUri: 'asset:card',
              actionLabel: 'Buy',
            ),
          ],
        ),
        ProductMessage(
          id: 'pr2',
          author: _shop,
          createdAt: ago(3),
          text: 'Prints you might like:',
          products: const [
            ChatProduct(
              id: 'dunes',
              title: 'Dunes',
              subtitle: 'A3 print',
              price: r'$18.00',
              imageUri: 'asset:dunes',
            ),
            ChatProduct(
              id: 'forest',
              title: 'Forest',
              subtitle: 'A3 print',
              price: r'$18.00',
              imageUri: 'asset:forest',
            ),
            ChatProduct(
              id: 'ocean',
              title: 'Ocean',
              subtitle: 'A2 print',
              price: r'$24.00',
              imageUri: 'asset:ocean',
            ),
            ChatProduct(
              id: 'sunset',
              title: 'Sunset',
              subtitle: 'A2 print',
              price: r'$24.00',
              imageUri: 'asset:sunset',
            ),
          ],
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        builders: const ChatBuilders(imageProviderBuilder: demoImage),
        contentCallbacks: ChatContentCallbacks(
          onProductTap: (message, product) =>
              toast(context, '${product.title} added to cart'),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Payments',
    description: 'Money requests you can pay or decline, and receipts.',
    icon: Icons.payments_outlined,
    builder: (_) => DemoChat(
      title: 'Payments',
      hint: 'Tap Pay or Decline on the request from Ana.',
      seed: () => [
        PaymentMessage(
          id: 'pay1',
          author: me,
          createdAt: ago(30),
          amount: r'$12.00',
          isRequest: false,
          note: 'Movie tickets',
          paymentStatus: ChatPaymentStatus.paid,
          status: MessageStatus.read,
        ),
        PaymentMessage(
          id: 'pay2',
          author: ana,
          createdAt: ago(4),
          amount: r'$36.50',
          note: 'Dinner on Friday',
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        contentCallbacks: ChatContentCallbacks(
          onPaymentAction: (message, action) {
            final paid = action == ChatPaymentAction.pay;
            c.update(
              message.copyWith(
                paymentStatus:
                    paid ? ChatPaymentStatus.paid : ChatPaymentStatus.declined,
              ),
            );
            toast(context, paid ? 'Paid ${message.amount}' : 'Declined');
          },
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Call log',
    description: 'Voice and video calls, missed or completed.',
    icon: Icons.call_outlined,
    builder: (_) => DemoChat(
      title: 'Call log',
      hint: 'Tap call back on an entry.',
      seed: () => [
        CallMessage(
          id: 'call1',
          author: ana,
          createdAt: ago(90),
          duration: const Duration(minutes: 12, seconds: 4),
        ),
        CallMessage(
          id: 'call2',
          author: me,
          createdAt: ago(45),
          kind: ChatCallKind.video,
          duration: const Duration(minutes: 3, seconds: 41),
        ),
        CallMessage(
          id: 'call3',
          author: ana,
          createdAt: ago(10),
          outcome: ChatCallOutcome.missed,
        ),
        CallMessage(
          id: 'call4',
          author: ana,
          createdAt: ago(2),
          kind: ChatCallKind.video,
          outcome: ChatCallOutcome.missed,
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        contentCallbacks: ChatContentCallbacks(
          onCallBack: (call) => toast(
            context,
            'Calling ${call.author.id == me.id ? ana.name : call.author.name}'
            ' (${call.kind.name})…',
          ),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Bot buttons and quick replies',
    description: 'Buttons inside a bubble and suggested answer chips.',
    icon: Icons.smart_button_outlined,
    builder: (_) => DemoChat(
      title: 'Buttons and replies',
      hint: 'Tap a button in the bubble, or a chip above the input to '
          'answer the bot.',
      seed: () => [
        TextMessage(
          id: 'b1',
          author: bot,
          createdAt: ago(2),
          text: 'Hi! Your order #4821 is on its way. What do you need?',
          buttons: const [
            ChatMessageButton(
              id: 'track',
              label: 'Track order',
              style: ChatButtonStyle.primary,
            ),
            ChatMessageButton(id: 'invoice', label: 'Get invoice'),
          ],
          quickReplies: const [
            ChatQuickReply(label: 'Change address'),
            ChatQuickReply(label: 'Talk to a human'),
            ChatQuickReply(label: '👍 All good', value: 'All good, thanks'),
          ],
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        contentCallbacks: ChatContentCallbacks(
          onMessageButton: (message, button) =>
              toast(context, 'Button: ${button.label}'),
          onQuickReply: (reply, message) async {
            sendText(c, OutgoingText(reply.text));
            c.setTyping(bot, isTyping: true);
            await latency();
            c
              ..setTyping(bot, isTyping: false)
              ..insert(
                TextMessage(
                  id: newId(),
                  author: bot,
                  createdAt: DateTime.now(),
                  text: 'Got it: "${reply.text}". Anything else?',
                ),
              );
          },
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'System messages',
    description: 'Centered notices between regular messages.',
    icon: Icons.info_outline,
    builder: (_) => DemoChat(
      title: 'System messages',
      hint: 'Notices sit between bubbles and have no author.',
      seed: () => [
        SystemMessage(id: 'sy1', createdAt: ago(20), text: 'Ana created Trip'),
        SystemMessage(id: 'sy2', createdAt: ago(19), text: 'Ana added Leo'),
        text('sy3', 'Welcome Leo!', minutesAgo: 18),
        text('sy4', 'Thanks 👋', author: _leo, minutesAgo: 17),
        SystemMessage(
          id: 'sy5',
          createdAt: ago(10),
          text: 'Leo renamed the group to "Trip to Lisbon"',
        ),
        text('sy6', 'Love the name', author: me, minutesAgo: 8),
        SystemMessage(id: 'sy7', createdAt: ago(3), text: 'Sam joined'),
        text('sy8', 'Hey all', author: _sam, minutesAgo: 2),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Custom message types',
    description: 'Your own message kinds rendered with your widgets.',
    icon: Icons.widgets_outlined,
    builder: (_) => DemoChat(
      title: 'Custom types',
      hint: 'The invoice uses a per-type builder. The last message has an '
          'unknown type and uses the fallback builder.',
      seed: () => [
        text('cu1', 'Here is the invoice for March', minutesAgo: 6),
        CustomMessage(
          id: 'cu2',
          author: ana,
          createdAt: ago(5),
          type: 'invoice',
          payload: const _Invoice(
            number: 'INV-0042',
            amount: r'$1,250.00',
            due: 'Due April 15',
          ),
        ),
        CustomMessage(
          id: 'cu3',
          author: ana,
          createdAt: ago(2),
          type: 'weather',
          payload: 'Sunny, 24°C',
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        builders: ChatBuilders(
          customMessageBuilders: {
            'invoice': (context, message, details) => _InvoiceCard(
                  invoice: message.payload! as _Invoice,
                  onTap: () => toast(context, 'Open invoice'),
                ),
          },
          customMessageBuilder: (context, message, details) => Padding(
            padding: const EdgeInsets.all(4),
            child: Text('Unsupported "${message.type}": ${message.payload}'),
          ),
        ),
      ),
    ),
  ),
]);

class _Invoice {
  const _Invoice({
    required this.number,
    required this.amount,
    required this.due,
  });

  final String number;
  final String amount;
  final String due;
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice, required this.onTap});

  final _Invoice invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: scheme.primary),
              const SizedBox(width: 8),
              Text(invoice.number, style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(invoice.amount, style: theme.textTheme.headlineSmall),
          Text(invoice.due, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: onTap,
            child: const Text('View invoice'),
          ),
        ],
      ),
    );
  }
}
