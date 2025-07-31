# GOV.UK Developer Docs Chatbot

A proof of concept. Not ready for use in earnest!

Limitations:
- Requires manually recompiling and re-uploading the Developer Docs to OpenAI
- Doesn't pull in the 'external' `docs/` documents from other repos
- No 'streaming' of answers, so quite slow
- Can only run on the developer's machine. Would be better exposed as a web page (behind BasicAuth)
- Context is lost between questions (so no ability for 'follow up' questions)
- Citations are pretty useless, as they refer to the uploaded txt files rather than the live Developer Docs page (which would be ideal)

## Requirements

A working OpenAI API account (at <platform.openai.com>) with:

- Payment method added (pay-as-you-go)
- Some credit added (e.g. $5).
  - Several queries to the chatbot end up costing a couple of cents. Monitor costs in real time at <https://platform.openai.com/settings/organization/usage>.

Once logged into your account, create an agent in the OpenAI platform:

- Visit <https://platform.openai.com/assistants> and click "Create"
- Give it a name (e.g. "GOV.UK Developer Docs Chatbot"
- For system instructions, add something like: `You are a helpful assistant trained on GOV.UK Developer Docs  (attached as files to this assistant). If the answer is not found in the documentation, respond with: "I don’t know based on the provided documentation"`.
- Enable the "File Search" toggle
- Add files by clicking on "Files" and then dragging the generated .txt files into the window and 'attach' them to the agent
- Set model as `gpt-4o-mini` (good balance of quality result vs low cost)

Create an API key for interacting with the agent, and store it somewhere safe - you'll need it later!

- <https://platform.openai.com/settings/organization/api-keys>

## Setup

Clone the govuk-developer-docs-chatbot repo and run `bundle install`.

Clone the govuk-developer-docs repo somewhere on your machine (if you haven't already) and expose the path to its `manual` folder, as an ENV var:

```
DEVELOPER_DOCS_DIR="/Users/christopher.ashton/govuk/govuk-developer-docs/source/manual"
```

Now, process the documentation (this grabs the docs from the DEVELOPER_DOCS_DIR and generates a `doc_chunks` directory in this repo):

```
bundle exec ruby doc_squasher.rb
```

## Usage

```
export OPENAI_API_KEY=<your key goes here>
export OPENAI_ASSISTANT_ID=<assistant ID goes here>
bundle exec ruby govuk_docs_cli.rb
```

Example output:

```
$ bundle exec ruby govuk_docs_cli.rb
GOV.UK Developer Docs Chat CLI (Ruby)
Ask a question or type 'exit' to quit.

>
```

Valid query:

```
> Explain how Static works
In progress
In progress
In progress
In progress
In progress
In progress
In progress
In progress

Static in the context of GOV.UK refers to several aspects related to asset delivery and page rendering for GOV.UK applications.

1. **Static Assets**: These are files such as stylesheets (CSS), JavaScript (JS), and images that compose the visual elements of GOV.UK. They are served from `https://www.gov.uk/assets` and are cached to improve load times. The cache layers proxy requests to the corresponding applications based on the specific asset path【4:1†source】【4:6†source】【4:11†source】.

2. **Static Templates**: Static hosts HTML snippets used by GOV.UK frontend applications for rendering consistent page layouts—like headers and footers. These templates can be accessed by both production instances of applications and for development purposes through `assets.publishing.service.gov.uk`, which acts as a public interface to access these resources【4:1†source】【4:11†source】【4:12†source】.

3. **Deployment and Maintenance**: The Static application must be deployed with care due to its role in serving partial pages that are heavily cached. This includes a specific deployment process that involves staging environments, a wait period for cache invalidation, and verification of functionality post-deployment【4:2†source】【4:16†source】.

4. **Caching Mechanisms**: Static leverages caching through tools like Slimmer to store and expire the responses efficiently. It plays a key role in serving repeated requests quickly and minimizes load on the servers【4:2†source】【4:17†source】. The caching strategy includes a default `cache-control` of 5 minutes for most assets, helping to maintain updated content while optimizing performance【4:17†source】.

These components function together to ensure that the GOV.UK website remains performant and visually consistent across various applications.
```

Invalid/unknown query:

```
> testing
Queued
In progress
In progress
In progress
In progress

I don’t know based on the provided documentation.

> exit
```

## Licence

[MIT License](LICENCE)
