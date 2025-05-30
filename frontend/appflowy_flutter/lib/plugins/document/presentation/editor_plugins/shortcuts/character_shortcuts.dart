import 'package:appflowy/plugins/document/application/document_bloc.dart';
import 'package:appflowy/plugins/document/presentation/editor_configuration.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/format_arrow_character.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/page_reference_commands.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/callout/callout_block_shortcuts.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/shortcuts/heading_block_shortcuts.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/shortcuts/numbered_list_block_shortcuts.dart';
import 'package:appflowy/plugins/document/presentation/editor_style.dart';
import 'package:appflowy/plugins/emoji/emoji_actions_command.dart';
import 'package:appflowy/plugins/inline_actions/inline_actions_command.dart';
import 'package:appflowy/plugins/inline_actions/inline_actions_service.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_plugins/appflowy_editor_plugins.dart';
import 'package:flutter/material.dart';

List<CharacterShortcutEvent> buildCharacterShortcutEvents(
  BuildContext context,
  DocumentBloc documentBloc,
  EditorStyleCustomizer styleCustomizer,
  InlineActionsService inlineActionsService,
  SlashMenuItemsBuilder slashMenuItemsBuilder,
) {
  return [
    // code block
    formatBacktickToCodeBlock,
    ...codeBlockCharacterEvents,

    // callout block
    insertNewLineInCalloutBlock,

    // quote block
    insertNewLineInQuoteBlock,

    // toggle list
    formatGreaterToToggleList,
    insertChildNodeInsideToggleList,

    // customize the slash menu command
    customAppFlowySlashCommand(
      itemsBuilder: slashMenuItemsBuilder,
      style: styleCustomizer.selectionMenuStyleBuilder(),
      supportSlashMenuNodeTypes: supportSlashMenuNodeTypes,
    ),

    customFormatGreaterEqual,
    customFormatDashGreater,
    customFormatDoubleHyphenEmDash,

    customFormatNumberToNumberedList,
    customFormatSignToHeading,

    ...standardCharacterShortcutEvents
      ..removeWhere(
        (shortcut) => [
          slashCommand, // Remove default slash command
          formatGreaterEqual, // Overridden by customFormatGreaterEqual
          formatNumberToNumberedList, // Overridden by customFormatNumberToNumberedList
          formatSignToHeading, // Overridden by customFormatSignToHeading
          formatDoubleHyphenEmDash, // Overridden by customFormatDoubleHyphenEmDash
        ].contains(shortcut),
      ),

    /// Inline Actions
    /// - Reminder
    /// - Inline-page reference
    inlineActionsCommand(
      inlineActionsService,
      style: styleCustomizer.inlineActionsMenuStyleBuilder(),
    ),

    /// Inline page menu
    /// - Using `[[`
    pageReferenceShortcutBrackets(
      context,
      documentBloc.documentId,
      styleCustomizer.inlineActionsMenuStyleBuilder(),
    ),

    /// - Using `+`
    pageReferenceShortcutPlusSign(
      context,
      documentBloc.documentId,
      styleCustomizer.inlineActionsMenuStyleBuilder(),
    ),

    /// show emoji list
    /// - Using `:`
    emojiCommand(context),
  ];
}
