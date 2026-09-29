---
name: idea
description: Capture and develop a new idea before anything is built. Interviews the owner, writes a living brief to docs/idea/BRIEF.md, and can gather product, UX, and architecture perspectives on it. Needs no code and no chosen stack. Use when the user types /idea.
disable-model-invocation: true
---

# Idea

Help the owner get an idea out of their head and into a brief they can build on. The owner may know very little yet. That is fine.

Role templates and the brief template are bundled next to this file:

```
${CLAUDE_SKILL_DIR}/foundry/agents/                  role templates
${CLAUDE_SKILL_DIR}/foundry/templates/idea/BRIEF.md  brief template
```

If `${CLAUDE_SKILL_DIR}/foundry/` is missing, stop and tell the owner to run `./install.sh` from their agent-foundry checkout.

What the owner typed after the command: `$ARGUMENTS`

## Rules for this skill

- **Capture first, critique later.** During the interview, listen and record. Do not evaluate the idea. The round of perspectives in Step 4 does that.
- **"I don't know" is an answer.** Record it as an open question and move on. Never press for an answer the owner doesn't have.
- **The owner's words.** The brief records what the owner said. Do not improve the idea, add features, or tidy it into something they did not say.
- **No technology talk unless the owner starts it.** Do not ask about stack, hosting, or tools. If the owner raises one, record what they said.
- **One question at a time, in conversation.** Ask in plain text and let the owner answer freely. Use AskUserQuestion only for a choice between a few fixed options.
- **Write early.** Write the brief once you know who it is for and what it does, then keep it updated. Nothing should be lost if the session ends.
- **Never invent.** A section with no answer reads "Not known yet." and adds an open question.
- **Do not commit or push.**

## Step 1: Find out where things stand

1. If `docs/idea/BRIEF.md` exists, this is a **continue** session. Go to Step 5.
2. If the folder has source code and no brief, tell the owner what you see and ask which applies:
   - *The idea is a feature for this project.* Recommend the project's pm agent and stop.
   - *The idea is a new project.* Recommend a new, empty folder and stop, unless the owner wants to continue here.
3. Otherwise this is a **new** idea. Go to Step 2.

## Step 2: Interview

Open with one invitation:

> Tell me about the idea, in whatever shape it's in.

Let the owner talk. Then cover what they did not, roughly in this order. Skip anything already answered.

| Topic | What you are listening for |
|---|---|
| The spark | What prompted this. A moment, a frustration, something they saw. |
| Who it is for | One person in one situation, not a demographic |
| The problem today | What that person does now, and what is wrong with it |
| What it does | What the person would see and do |
| The smallest useful version | The least that would be worth showing someone |
| What it is not | What the owner has already ruled out |
| Success | How they would know it worked |
| Constraints | Time, money, skills, deadlines |
| What kind of thing it is | An app, a device, a service, content, or not sure yet |
| Worries | What they think could go wrong |
| Working title | Any name will do. It can change. |

How to run it:

- Every three or four answers, reflect back what you heard in two sentences and ask whether you have it right.
- Follow the owner's energy. If they want to talk about one part, stay there.
- Stop when the owner wants to stop. Offer to stop after about ten questions, or once you know who it is for, the problem, what it does, and the smallest version.

**Non-interactive runs.** If you cannot ask questions, take the idea from the arguments, ask nothing, and record everything unknown as an open question.

## Step 3: Write the brief

Read `${CLAUDE_SKILL_DIR}/foundry/templates/idea/BRIEF.md` and write `docs/idea/BRIEF.md`.

- Replace `{{PROJECT_NAME}}` with the working title. If there is none, use "Untitled idea" and add an open question.
- Replace every `{{FILL: ...}}`. The text after `FILL:` is an instruction to you.
- Quote the owner where their phrasing carries the meaning.
- Put every "I don't know" under Open questions, with why the answer matters.
- Put only what the owner decided under Decided. A suggestion from you is not a decision.

Show the owner the brief and ask what is wrong or missing. Correct it.

## Step 4: A round of perspectives

Offer this once the brief covers who it is for, the problem, and what it does. Say what it involves before you start:

> I can get three perspectives on this: product, user experience, and architecture. That launches three agents and takes a few minutes. Want me to run it?

Run it only if the owner agrees.

### Who to launch

- If this project's planning agents are installed and available in this session, launch them by name.
- Otherwise launch a `general-purpose` agent for each role. Build its prompt from three parts:
  1. The role template at `${CLAUDE_SKILL_DIR}/foundry/agents/<role>.md`, with this note: "Nothing is built yet. Ignore the template tokens and fill instructions. Take the role, the method, and the standards."
  2. The full text of the brief
  3. The questions for that role, below

Launch them in a single message so they run in parallel.

### What to ask each one

| Role | Questions |
|---|---|
| **pm** | Is the problem real and specific? Who is the first user? What is the smallest version worth building, and what would you cut from the owner's version? What would make you say "don't build this"? |
| **ux** | Walk through the person's moment from start to end. Where is the friction or the doubt? What has to feel right for this to work? Which states matter most? |
| **architect** | What forms could this take? Compare two or three approaches, including the simplest one. What should be prototyped first to retire the biggest risk? Which decisions can wait? Do not choose a stack unless the brief asks for one. |

Add **social** if the idea depends on reaching an audience, or **security** if it handles sensitive data. Tell the owner if you add one.

Tell every agent:

- Ground in the brief. There is no code.
- Label each assumption you make.
- End with your three most important questions for the owner.

### Synthesis

Write `docs/idea/rounds/YYYY-MM-DD.md`. If that file exists, add `-2`, `-3`, and so on.

```markdown
# Round: YYYY-MM-DD

## Where they agree
## Where they disagree
## Questions for the owner, most important first
(at most five, each with who raised it and why it matters)
## Suggested next step
## Perspectives
### Product
(the agent's response, in full)
### User experience
### Architecture
```

Link the file under Rounds in the brief.

Then take the questions to the owner one at a time. Update the brief with each answer: a decision goes under Decided with the date and the reason, and an "I don't know" stays under Open questions.

An agent's recommendation is not a decision. Nothing moves to Decided until the owner says so.

## Step 5: Continue a session

1. Read the brief and the newest round.
2. Report where things stand in a few lines: what is known, what was decided last, how many questions are open.
3. If the arguments name a topic, start there. Otherwise ask which open question the owner wants to work on.
4. Update the brief as the owner answers. Set "Last updated".
5. Offer a new round when the brief has changed in substance since the last one.

## Step 6: Report

```
Idea: <working title>
Brief: docs/idea/BRIEF.md (<new | updated>)

Known:
  Who: <one line, or "not known yet">
  Problem: <one line>
  What it does: <one line>
  Smallest version: <one line>
Decided this session: <list, or "nothing">
Open questions: <count>. The top three: <list>
Round: <path, or "not run">

Next:
- /idea to keep developing it
- /foundry-init to set up a planning team that knows this brief
- /blueprint to plan how it gets built, once you know who it is for, what it does, and the smallest useful version
```
