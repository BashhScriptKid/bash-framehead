# ext/neural/data — Corpus Data

## Files

### `conv.txt`
Conversation corpus. Each line is a dialogue turn with utterances separated by
`__eou__` (end-of-utterance). Tab-separated metadata follows each line.

Source: migrated from `llm/ngram/data/conv.txt`.

### `vocab.txt`
Small reference vocabulary showing the format. The full vocabulary is built
dynamically during `neural::ngram::train` by scanning the corpus.

## Format

Training data is line-oriented text. Each line is one or more sentences.
Tokens are space-separated, lowercased during training. No special preprocessing
is required beyond what `neural::data::tokenize` handles.
