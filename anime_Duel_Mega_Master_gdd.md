Anime Duel — Super Master Game Design Document

Document type: Super Master GDD / vertical-slice source of
truth
Working title: Anime Duel
Target build: v1 first playable / vertical slice
Engine: Godot
Platform: PC
Input model: Keyboard-first

1. How to Use This Document
This document is the unified reference for the vertical slice.

It combines:

a full standalone design brief for the game’s identity and intended
player experience,

the previously developed duel philosophy from the creative question
rounds,

and the numeric / logic backbone from the existing master GDD.

Precedence Rules
If different sections ever seem to conflict, use this order:

Locked rules and numeric tables in this document

Core design pillars and duel grammar

Character identity and UX/readability goals

Implementation notes and production convenience

This document is written to help a developer both understand what the
game isandbuild it without guessing the intended feel.

2. Game Summary
*Anime Duel* is a stylish anime-inspired duel game built around:

simultaneous hidden action selection,

short keyboard execution challenges,

readable duel-state consequences,

and cinematic playback.

Every exchange begins with both fighters secretly choosing an action
under time pressure. The system resolves the intent matchup first, then
asks the player to perform a short skill challenge that expresses that
action physically. The result updates HP, Guard, meter, and pressure
state, then becomes a short anime-style combat beat with VFX, hit stop,
camera work, and dramatic framing.

The game should feel:

strategic,

tense,

skillful,

fair,

readable,

and anime-cool.

The vertical slice is deliberately narrow:

2 playable characters

1 arena

3 AI difficulties

3 core mini-games

1 duel mode

no progression

no multiplayer

no story campaign

The slice exists to prove:

the duel loop is fun enough to replay,

the mini-games feel like duel expression rather than interruption,

Guard and Vulnerable create meaningful escalation,

the two characters feel distinct,

the match presentation already feels like an anime clash.

3. Core Hook
This is a one-round anime duel where the player wins by:

making the right read,

staying composed,

and turning that read into action through a brief test of execution.

The game’s essence is:

**Hidden intent + nerve under pressure + meaningful duel-state
consequence + cinematic anime payoff**

The game is not about raw typing speed.

It is not about giant move lists.

It is not about memorizing fighting-game inputs.

It is about tense, readable clashes where each turn asks:

“What do you think they are doing?”

“Are you calm enough to commit?”

“Can you carry that decision through the moment?”

4. Player Fantasy
The fantasy is to be a duelist who:

reads the opponent,

keeps composure under pressure,

survives tight moments,

and turns a small opening into a decisive anime beat.

The player should most often feel:

“I made the right call.”

“I held my nerve.”

“I was punished for getting predictable.”

“That Guard Break changed the whole duel.”

“That was my fight, not just a mechanic.”

Winning should usually feel like:

a correct read plus execution,

calm under pressure,

or a decisive moment of control.

Losing should usually feel like:

being outread,

overcommitting,

panicking,

or mismanaging the duel state.

Those are good losses because they create the desire for an immediate
rematch.

5. Design Pillars
5.1 Read First, Execute Second
The target combat philosophy is roughly 60% read / 40% execution.

5.2 One Exchange Must Carry the Whole Game
A single good exchange must already contain:

hidden intent,

execution,

consequence,

and anime payoff.

5.3 Mini-Games Must Express Duel Intent
Each challenge must feel like the physical form of the chosen action.

5.4 Spectacle Must Clarify
Presentation should heighten the emotional truth of an exchange without
making the system harder to read.

5.5 Tight Scope, High Signal
The vertical slice proves the concept through clarity and feel, not
content scale.

5.6 Fairness Over Density
The player should understand why something happened. Mystery is allowed
in psychology, not in rules feedback.

6. Scope Snapshot
In Scope
single-player vs AI

one-round duel

simultaneous hidden action planning

7-second turn timer

Attack / Defend / Evade / Special

Attack subtypes: Fast / Power / Precision

HP / Guard / Meter

Guard Break and Vulnerable

3 mini-games

2 characters

1 arena

3 AI difficulties

post-fight highlight replay

minimal onboarding

debug and telemetry support

Out of Scope
online multiplayer

local PvP

progression systems

unlock tree

account meta

large roster

multiple arenas

full training mode

deep narrative campaign

rebinding UI

terrain hazards

gameplay wall system

full deterministic replay reconstruction

7. Intended Player Experience
By the end of an early duel, the player should feel:

“I understand what the choices mean.”

“I lost because I guessed wrong, executed poorly, or both.”

“Fast, Power, and Precision feel genuinely different.”

“Guard pressure matters.”

“The replay made the fight feel even cooler.”

“I want another match.”

Target emotional sequence inside a strong duel:

probing

recognition

pressure

crack

decisive commitment

memory

8. High-Level Game Flow
Title Screen

Character Select

Difficulty Select

Duel Intro

Repeated exchange loop

Match End

Highlight Replay

Result Screen

Post-fight options:

rematch

switch character

switch difficulty

return to title

A duel is a single round with no between-round reset.

9. Match Pacing Targets
Target duel length: 2–3 minutes

Average exchanges per duel: 8–12

Average exchange length including playback: 8–12 seconds

Final blow: always receives extra presentation weight

Intensity curve: visually and emotionally rises as Guard cracks
and HP drops

Small exchanges stay quick.

Guard Breaks, Specials, Perfects, and finishers receive more breathing
room.

10. Core Combat Resources
10.1 HP
Primary defeat resource.

If HP reaches zero, that fighter loses.

10.2 Guard
Represents composure, defensive stability, and pressure tolerance.

Guard is:

reduced by pressure,

reduced by failed defensive moments,

reduced by some direct hits,

strongly targeted by Power and Specials,

recovered through breathing room, success, and stabilization,

breakable.

Guard is the main pressure escalator in the game. It is not merely bonus
health.

10.3 Meter
Used for Specials.

10.4 Starting Values
HP: 100

Guard: 100

Meter: 0 / 100

Meter can hold enough for 2 Specials.

11. Duel Grammar
Every exchange follows this sentence:

Intent → Baseline Contest → Execution Grade → Consequence → Playback

Intent
Both sides commit secretly to a duel answer.

Baseline Contest
The combat matrix determines the relationship between those choices.

Execution Grade
Mini-game performance modifies the result.

Consequence
HP, Guard, meter, Guard Break, Vulnerable, and perceived momentum
update.

Playback
The system dramatizes the exchange in anime form.

If the player can follow those five steps emotionally, the game feels
coherent.

12. Core Turn Structure
12.1 Planning Timer
Each exchange begins with a shared 7-second planning phase.

12.2 Hidden Lock-In
Player and AI choose simultaneously from the player’s perspective.

12.3 Choice Editing
The player can change selection until the timer ends or they confirm
early.

12.4 Early Confirm
The player may confirm early for pacing.

No hidden gameplay bonus is granted.

12.5 Timeout Behavior
If time runs out:

highlighted choice is used, or

if nothing is selected, the game performs Auto-Defend.

Timeout can never result above Weak grade.

12.6 Reveal Pause
Post-lock reveal pause: 0.45 seconds

12.7 Reset Breath
Post-playback reset beat: 0.6 seconds

12.8 Simultaneous Death
Double KO is allowed and results in a Draw.

13. Action Set
Top-level actions:

Attack

Defend

Evade

Special

If Attack is selected, the player chooses:

Fast

Power

Precision

No hard cooldowns in v1.

Anti-spam comes from:

matchup logic,

pressure consequences,

punish on Miss,

Guard dynamics,

character identity,

AI adaptation.

14. Action Identity
14.1 Attack
Primary pressure category.

14.2 Defend
Safest general stabilizer.

Should feel like disciplined control, not passive waiting.

14.3 Evade
Hard-read punish tool.

Should feel rare, sharp, and disrespectful when correct.

14.4 Special
An earned rule-breaker with visible conditions and meter cost.

15. Attack Subtype Identity
Fast
Role:

pace

safety

control

consistency

tempo

Properties:

lower HP damage

lower commitment

safer on failure

decent meter generation

can sometimes clip shallow Evade

least grade-sensitive attack subtype

Fantasy:

calm pressure and control
Power
Role:

Guard pressure

force

punishment threat

Properties:

highest Guard damage

strong HP damage

best anti-Defend option

punishable when read

worst baseline into Evade

heavier presentation language

Fantasy:

committed dominance and crack potential
Precision
Role:

hardest punish

highest execution ceiling

sharpest payoff

Properties:

hardest mini-game

highest reward on Perfect

weakest on Miss

more sensitive to matchup and grade quality

riskier into Evade

strongest “I earned this” emotion

Fantasy:

lethal exactness under pressure
16. High-Level Interaction Model
The game uses a readable rock-paper-scissors backbone with added
texture.

Visible structure:

Attack pressures

Defend stabilizes

Evade hard-punishes commitment

Special bends the rules but is still contestable

Important principles:

Defend blunts attacks but usually does not erase all pressure

Power is strongest into Defend

Evade hard-punishes the right heavy read

Specials are not free wins

Same-subtype mirrors resolve mainly through grade

17. Baseline Matchup Logic
The combat matrix outputs one of:

`strike`

`guarded_strike`

`whiff_punish`

`clash`

`neutral_reset`

`special_event`

It should also return:

baseline winner

baseline loser

exchange state

mini-game owner

mini-game type

grade sensitivity

damage modifier

Guard modifier

meter modifier

17.1 Universal Baseline Matrix
P1	P2	Baseline
Fast	Fast	clash
Fast	Power	strike (Fast favored)
Fast	Precision	strike (Fast favored)
Power	Fast	strike (Power disfavored)
Power	Power	clash
Power	Precision	strike (Precision favored)
Precision	Fast	strike (Precision disfavored)
Precision	Power	strike (Precision favored)
Precision	Precision	clash
Fast	Defend	guarded_strike
Power	Defend	guarded_strike (attacker favored)
Precision	Defend	guarded_strike (defender slightly favored)
Fast	Evade	strike / soft whiff-punish lean
Power	Evade	whiff_punish
Precision	Evade	soft whiff_punish
Defend	Defend	neutral_reset
Defend	Evade	neutral_reset
Evade	Evade	neutral_reset
Attack	Special	special_event
Defend	Special	special_event
Evade	Special	special_event
Special	Special	special_event
17.2 Human-Readable Interpretation
Fast vs Defend: low HP, medium Guard pressure

Power vs Defend: attacker advantage, strong Guard pressure

Precision vs Defend: defender slight advantage unless attacker
executes well

Fast vs Evade: attacker slight advantage, but clean Evade can
still win

Power vs Evade: Evade strongly favored

Precision vs Evade: soft Evade advantage

Defend vs Defend: reset and recover

Defend vs Evade: restrained neutral

Evade vs Evade: hard reset

Special vs Special: cinematic contest

17.3 Same-Subtype Rule
If both sides choose the same attack subtype:

higher grade wins

equal grade usually results in clash / neutralized exchange

there is no hidden speed stat in v1

18. Quick Resolve / Low-Impact Exchange Rules
Not every exchange needs a foreground mini-game.

18.1 Low-Impact Definition
An exchange is low-impact if:

neither side used an attack or active Special,

the baseline result is neutral or stabilization,

and meaningful HP swing is not expected.

18.2 Allowed Quick Resolve Pairings
Defend vs Defend

Evade vs Evade

Defend vs Evade

Evade vs Defend

invalid Special fallback that becomes Auto-Defend equivalent

18.3 Quick Resolve Properties
Quick Resolve:

shows Quick Resolve, not a grade

may grant meter

may grant Guard recovery

cannot cause KO

cannot cause Guard Break

cannot cause chip damage

cannot create whiff recovery

18.4 Quick Resolve Meter Gains
neutral reset: +3

evade-favored reset: +4

19. Mini-Games
The vertical slice uses exactly 3 mini-games:

Typing

Pattern Input

Reaction Timing

Only one visible foreground mini-game appears to the player in
single-player.

The AI’s execution is simulated in the background.

19.1 Integration Rule
A challenge only belongs in the game if it feels like the body of the
action chosen.

19.2 Primary Mapping
Fast → Pattern Input

Power → Reaction Timing

Precision → Typing

Defend → Reaction Timing

Evade → short Pattern Input

Martial Artist Special → Pattern Input

Samurai Special → Reaction Timing

19.3 Mapping Frequencies
Fast uses Pattern 90%

Power uses Timing 95%

Precision uses Typing 95%

19.4 Repetition Rule
The same mini-game can appear twice in a row, but not more than 2
consecutive times unless forced by a Special.

20. Mini-Game Definitions
20.1 Typing
Use for deliberate, exacting, high-stakes input.

Rules:

English only

lowercase only

punctuation ignored

short real words and phrases

QWERTY keyboard only

Prompt pool target:

120 prompts

maximum prompt length: 14 characters

Examples:

`dash`

`parry`

`steel rain`

`draw cut`

`counter flow`

Scoring:

70% accuracy + 30% speed

one typo removes Perfect

quick correction can still preserve Good

Backspace allowed

20.2 Pattern Input
Use for flow, movement, and evasive control.

Rules:

sequence lengths: 3 / 4 / 5

recommended launch set: A S D J K L

arrows are acceptable fallback framing

no mouse input

20.3 Reaction Timing
Use for impact, discipline, and decisive timing.

Variants:

Standard center stop

Faster sweep

Narrower Good zone

Heavy delayed-start version

No fake-outs in v1.

20.4 Data-Driven Rule
Each mini-game is data-driven and should have a dedicated debug/test
scene.

21. Grade System
Universal result labels:

Miss

Weak

Good

Perfect

Grade Design Intent
Perfect is rare and hype

Miss should come from panic, hard execution, or severe misplay

Correct reads matter more than raw grade

Precision is more grade-sensitive than Fast

Defensive exchanges are less swingy than offensive ones

Grade Philosophy
Baseline matchup happens first

Grade modifies baseline more often than replacing it

A Miss on a favorable read can reverse the exchange

A Perfect on a bad read can salvage a soft disadvantage, but should
not reliably beat a hard counter

Correct strategic decisions should grant some value unless the player
fails badly

22. Grade Thresholds by Mini-Game
22.1 Pattern Input
Miss: wrong key, wrong order, or timeout

Weak: one correction / late completion inside grace

Good: correct sequence inside standard time

Perfect: clean and fast

Allowed times:

3 keys: 1.2s

4 keys: 1.6s

5 keys: 2.0s

22.2 Reaction Timing
Normalized windows:

Miss: outside ±0.24

Weak: ±0.24 to ±0.11

Good: ±0.11 to ±0.04

Perfect: inside ±0.04

22.3 Typing
Score formula:

70% accuracy

30% speed

Bands:

Miss: <70% accuracy or timeout

Weak: 70–89% accuracy or slow completion

Good: 90–99% accuracy in target time

Perfect: 100% accuracy in tight time

23. Damage, Guard, and Outcome Math
23.1 Numeric Style
Use flat base values with light modifiers.

23.2 Base HP Damage Table
Action	Miss	Weak	Good	Perfect
Fast	0	6	10	14
Power	0	10	16	24
Precision	0	8	14	28
23.3 Base Guard Damage Table
Action	Miss	Weak	Good	Perfect
Fast	0	8	12	16
Power	0	14	22	30
Precision	0	6	12	18
23.4 Grade Modifiers
Miss: 0.0

Weak: 0.75

Good: 1.0

Perfect: 1.2

23.5 Core Formula
`Final = round((Base × matchup modifier × grade modifier × character
modifier) + vulnerability bonus)`

Ordering:

baseline matchup

grade modifier

character modifier

Vulnerable bonus

final integer rounding

23.6 Floors and Ceilings
successful non-zero outcome floor: 1

max single-exchange HP damage in v1: 32

23.7 Combat Math Notes
Power on Weak still creates minimum Guard pressure when not evaded

Fast may create control and Guard pressure even with minimal HP damage

Defend can turn weak offense into stabilization

Small successful reads still need to feel real, even if numbers stay
modest

24. Meter System
24.1 Meter Basics
Max: 100

Special cost: 50

Meter is spent on successful Special activation at reveal

No refund on failed Special

Up to 2 Specials can be stored

24.2 Meter Gain Table
Land hit: +8

Be hit: +5

Successful Defend: +6

Successful Evade: +8

Perfect bonus: +5

Guard Break caused: +8

Quick Resolve neutral: +3

Quick Resolve evade-favored: +4

24.3 Meter Philosophy
Meter is an escalation tool, not a snowball gimmick.

It should support dramatic state changes without turning the game into
guaranteed comeback math.

25. Guard System
25.1 Guard Loss Sources
Guard is reduced by:

blocked pressure

failed Defend

direct hits

punish states

Specials

25.2 Guard Recovery
Recovery occurs after exchange resolution and before next planning.

Recovery values:

passive after non-hit exchange: +4

successful Defend: +12

successful Evade: +12

Defend vs Defend: +10 both

Defend vs Evade: Defend +8, Evade +10

Guard does not recover while Vulnerable.

25.3 Guard Design Truth
Guard exists so a duel can tighten before it ends.

The player should emotionally read Guard as:

composure holding,

composure cracking,

or composure broken.

26. Guard Break and Vulnerable
26.1 Guard Break
When Guard breaks:

the defender remains interactive,

the attacker gains next-exchange advantage,

no free combo occurs,

a strong cinematic beat plays.

After the Vulnerable exchange resolves, Guard resets to 35.

26.2 Vulnerable
Vulnerable is a 1-exchange debuff that:

makes the target easier to pressure,

worsens stabilization,

prevents Guard recovery,

increases attacker payoff,

and sharpens presentation.

It expires if:

both sides Defend, or

the advantaged side whiffs.

26.3 Vulnerable Effects
attacker gets +10% HP modifier

attacker gets +15% Guard modifier

defender thresholds worsen by ~10%

attacker thresholds ease by ~5%

Defend and Evade recover 4 less Guard

some baselines improve by one step

presentation intensity increases

26.4 Design Meaning
Vulnerable should feel like a cracked mental state, not an artificial
stun.

27. Characters
The vertical slice has exactly 2 fighters.

27.1 Shared Structure
Both use:

the same action set

the same resources

the same overall duel grammar

They differ through:

tuning

passive identity

Special

feel

emotional pacing

presentation flavor

27.2 Martial Artist
Identity:

flow

rhythm

smoother recovery

stronger Fast identity

more beginner-friendly

Passive: Flow Pressure

Fast Good/Perfect: +2 bonus meter

Successful Evade: +2 extra Guard recovery

Fast Weak uses 90% normal self-risk

Special: Momentum Rush

condition: own HP ≤ 50

cost: 50 meter

mini-game: Pattern Input

one grade for entire sequence

Perfect branches to stronger finisher presentation

Results:

Miss: self -10 Guard

Weak: 12 HP / 12 Guard

Good: 18 HP / 18 Guard

Perfect: 26 HP / 22 Guard and restore 10 own Guard

vs Vulnerable target: +3 HP, +3 Guard

27.3 Samurai
Identity:

deliberate pace

stronger Power/Precision fantasy

higher punish ceiling

harsher commitment

more expert-leaning

Passive: Lethal Read

Power Perfect: +2 Guard damage

Precision Perfect: +4 HP damage

Power/Precision Miss self-risk: +10%

Special: Decisive Cut

condition: opponent Guard ≤ 35

cost: 50 meter

mini-game: Reaction Timing

high-risk punish / finisher strike

Results:

Miss: self -12 Guard, exposed

Weak: 14 HP / 10 Guard

Good: 22 HP / 16 Guard

Perfect: 32 HP / 20 Guard

vs Vulnerable target: +4 HP

Perfect vs Vulnerable: dramatic finisher camera

27.4 Character Balance Target
Acceptable win-rate difference in tests: ≤8%

27.5 Emotional Character Contrast
The Martial Artist should feel like composed flow.

The Samurai should feel like lethal certainty.

That emotional difference matters as much as tuning.

28. Special System Rules
28.1 Core Rules
chosen within the normal planning menu

no extra confirm

each Special uses one fixed mini-game in v1

Specials can be contested or interrupted by matchup logic

Special vs Special is rare and cinematic

28.2 Activation Checks
Validity is checked:

on selection

again at reveal

If valid during planning but invalid at reveal:

it does not fire,

it downgrades to an Auto-Defend-equivalent fallback,

a penalty/disadvantage applies.

28.3 Special Presentation
at least 2 camera cuts

clearly above normal attacks in spectacle

special-event logic for Special vs Special

28.4 Design Meaning
A Special is an earned declaration of intent, not a panic button.

29. AI Design
29.1 Philosophy
The AI should feel like it is using the same duel logic as the player.

It must not feel psychic.

Difficulty should affect:

choice quality

execution grade odds

punish logic

adaptation

randomness

use of pressure states

29.2 Difficulty Personalities
Easy
readable habits

more randomness

repeats mistakes

weak Special timing

low bluff rate

Normal
balanced reads

basic punish logic

moderate adaptation

memory of 1 recent turn

bluff frequency around 10%

Hard
punishes repetition

stronger state awareness

sharper Special timing

less randomness

memory of last 2 turns

bluff frequency around 15–20%

29.3 AI Decision Inputs
AI scoring should consider:

self HP / Guard / meter

opponent HP / Guard / meter

opponent Special availability

Vulnerable state

player’s last 2 actions

repeated categories

active Special conditions

29.4 AI Heuristics
safer on low HP

more Power into low enemy Guard

more Evade into repeated Power

intentionally imperfect choices for human feel

pattern-based adaptation

29.5 Simulated Execution Odds
Difficulty	Miss	Weak	Good	Perfect
Easy	20%	45%	30%	5%
Normal	10%	25%	50%	15%
Hard	4%	16%	50%	30%
Type modifiers:

Precision / Typing: +4% Miss, -4% Perfect

Fast / Pattern: no change

Power / Timing: -2% Miss, +2% Good

29.6 AI Trust Goal
The player should be able to say:

“The AI noticed my habit.”
not

“The AI read my input.”
30. Controls and Input Language
30.1 Menu / Action Selection
`1 / 2 / 3 / 4` = Attack / Defend / Evade / Special

After choosing Attack:

`Q / W / E` = Fast / Power / Precision

`Enter` = confirm early

`Esc / Backspace` = go back

30.2 Input Feel Targets
Attack submenu appears in <100 ms

no avoidable delay before subtype selection

tiny input buffering allowed between turns

30.3 Layout Assumptions
keyboard-only

QWERTY support only in v1

rebinding not required yet

31. First-Time Player Flow
Duel 1 must prove:
the game is about choosing intent

the player has real responsibility

the system is readable

Duel 2 must prove:
Guard matters

pressure can accumulate

the player can lose because of habit, not randomness

Duel 3 must prove:
the AI adapts

character identity matters

rematches are about learning

By the end of the first three duels, the player should understand:

what the four main actions mean

how Fast / Power / Precision differ

why Guard is important

that the game rewards reads more than panic execution

and that there is a reason to improve

32. Onboarding and Tutorial
32.1 Philosophy
Minimal onboarding. No giant tutorial.

32.2 Format
A short guided sandbox duel plus contextual early tips.

32.3 Tutorial Specifics
default tutorial character: Martial Artist

first guided action: Attack → Fast

should deliberately demonstrate:

one mini-game

one Guard Break

one Special

preview tags

HP vs Guard difference

grade labels

Vulnerable

32.4 Duration
Maximum acceptable tutorial length: 90 seconds

32.5 What Must Be Understood Quickly
timer

action menu

attack subtypes

grades

Guard vs HP

Guard Break / Vulnerable

Special condition and cost

33. UI / UX
33.1 Layout
battle view dominates screen

bottom command picker

minimal HUD

33.2 Always Visible
player HP / Guard / Meter

enemy HP / Guard / Meter

planning timer

grade splash when relevant

33.3 Placement
planning timer: top-center

player resources: top-left

enemy resources: top-right

meter below HP/Guard stack

33.4 Guard UI
Guard shown as a bar

color shift at low values

33.5 Special UI
locked Special visible but greyed out

requirement text shown on focus

no explicit AI prediction text

33.6 Preview System
Preview is hover/focus-driven and limited.

Max tags shown at once: 2

Allowed vocabulary:

Strong

Risky

Break Guard

Good vs Power

Good vs Low Guard

Comeback

Finisher

Unsafe if Missed

Preview must never lie.

33.7 Explanation System
Important exchanges should display a short explanation line.

Rules:

center-bottom above picker

max 6 words

references visible logic only

Examples:

`Fast Good interrupted Power.`

`Power Perfect cracked Guard.`

`Evade punished a heavy read.`

`Precision Miss gave up the exchange.`

33.8 UX Goal
The player should clearly know whether they:

chose wrong,

executed poorly,

or both.

34. Presentation and Combat Readability
34.1 Visual Philosophy
Anime-inspired presentation through:

hit stop

impact flash

screen shake

slash trails

speed lines

camera cuts

slow motion

freeze-frames on big beats

34.2 Camera Language
Baseline:

mostly side-on

close-ups on important beats

angled cut-ins for Specials and finishers

34.3 Camera Budget
low impact: 0–1 cuts

normal exchange: 1 cut

important exchange: 2 cuts

Special / finisher: 2–3 cuts max

34.4 Camera Triggers
Close-ups on:

Perfect

Guard Break

Special start

Special hit

finisher

major whiff punish

34.5 Presentation Flavor by Action
Fast: snappy, short shots

Power: heavy shake and weight

Precision: cleaner pauses and surgical emphasis

34.6 Slow Motion Triggers
Perfect

Guard Break

Special hit

final blow

34.7 Miss Presentation
Misses must communicate failure clearly without turning comedic.

34.8 Readability Rule
If presentation makes the player less able to understand the duel state,
tone it down.

35. Replay / Director System
35.1 Replay Goal
Make the fight feel even more memorable after it ends.

35.2 Replay Form
automatic after fight

instantly skippable

condensed highlights, not full reconstruction

UI-free

more dramatic timing than live play

35.3 Replay Length
total length: 10–20 seconds

3–6 highlight moments

include one setup/context shot

shorten automatically if match was dull

35.4 Forced Moments
Always include:

final blow

Guard Break

double KO if present

35.5 Replay Importance Scoring
Event	Score
Perfect	+3
Guard Break	+4
Special	+4
20+ HP hit	+3
Vulnerable punish	+2
Finisher	+5
Double KO	+5
35.6 Logged Data per Exchange
Minimum logging:

turn index

both chosen actions and subtypes

Special condition state

visible grade / simulated AI grade

baseline state

HP delta

Guard delta

meter delta

Guard Break flag

Vulnerable flag

Special fired

KO / finisher / draw flags

replay importance score

camera tags

explanation key

35.7 Replay Design Truth
The replay should deepen memory, not rescue a weak exchange.

36. Arena
36.1 Theme
A stylized dusk shrine rooftop courtyard.

36.2 Philosophy
Presentation-only arena in v1.

Supports:

sparks

dust bursts

slash trails

impact debris

speed-line overlays

light prop reactions

Does not support:

hazards

terrain advantage

gameplay wall mechanics

36.3 Lighting
One lighting setup for v1.

37. Technical Architecture
37.1 Core Approach
Use:

one combat scene

reusable mini-game overlays

state machine + data table hybrid

editable data resources

simplified replay logs

37.2 Combat State Machine
Recommended states:

Init

Intro

Planning

Confirm

Reveal

ResolveBaseline

SpawnMiniGame

MiniGameActive

ResolveOutcome

Playback

Recovery

CheckEnd

Replay

Result

37.3 Central Controller
One master `CombatController`.

37.4 Data Representation
Use enums for action flow and resources/data files for balance.

37.5 Required Data Containers
`BalanceData`

`CharacterData`

`MiniGameData`

37.6 ExchangeResult Packet
Each exchange resolves into a packet containing:

`turn_index`

`p1_action`

`p1_subtype`

`p2_action`

`p2_subtype`

`baseline_state`

`mini_game_type`

`mini_game_owner`

`p1_grade`

`p2_grade_abstract`

`hp_delta_p1`

`hp_delta_p2`

`guard_delta_p1`

`guard_delta_p2`

`meter_delta_p1`

`meter_delta_p2`

`vulnerability_applied`

`guard_break`

`special_fired`

`camera_tags`

`explanation_key`

37.7 Debug Support
Include:

deterministic seed logging

in-game debug overlay

debug commands to force:

Guard Break

Special availability

specific mini-game

specific grade

37.8 Performance Target
60 FPS
38. Production Scope and Asset Strategy
38.1 Minimum Character Animation Set
Each character needs:

idle / stance

intro pose

hit react

defend pose

evade pose

Fast strike base

Power strike base

Precision strike base

Special base

finisher hit

38.2 Safe Reuse
Can reuse with timing/camera variation:

Fast family

Power family

some Defend/Evade recoveries

some contact reactions

38.3 Mandatory VFX
hit spark

slash trail

impact flash

screen shake

speed lines

Guard crack effect

38.4 Mandatory Sounds
UI confirm

timer warning

light hit impact

heavy hit impact

Guard hit

Guard Break

Special charge / cut

38.5 Visual Direction
Preferred:

stylized low-poly

cel-shaded lean

not pixel-filtered

38.6 Most Dangerous Missing Asset
Weak hit feel.

39. Acceptance Criteria
The vertical slice is accepted when:

The player can complete a full duel from title to results.

Hidden action selection and timer function correctly.

Attack / Defend / Evade / Special all work.

Attack branches into Fast / Power / Precision.

All 3 mini-games are playable and integrated.

Grades affect visible duel outcomes.

HP, Guard, and Meter all work.

Guard Break creates Vulnerable without removing defender agency.

Martial Artist and Samurai feel distinct in play and presentation.

AI supports 3 difficulties and both fighters.

The match is readable without dense UI.

The fight already feels anime-inspired.

The post-fight replay works and highlights dramatic moments.

The build is stable enough for external testing.

40. Success Metrics
Primary
Players say the duel is replayable.

Players say the mini-games feel integrated.

Players say the fight feels like an anime clash.

Secondary
Players understand the action structure quickly.

Players can explain Fast / Power / Precision differences.

Players feel character identity.

Players understand why they won or lost.

Players want to rematch.

Strong Positive Playtester Quotes
Examples:

“I got read.”

“I panicked there.”

“That Guard Break changed everything.”

“The AI noticed my habit.”

“I want one more.”

Warning Quotes
Examples:

“It looks cool, but I don’t know why.”

“It’s just typing with effects.”

“I picked the same thing every time.”

“I only cared about the replay.”

41. Balance Philosophy
Healthy long-term behavior:

Fast: safe tempo tool

Power: Guard pressure threat

Precision: high-skill payoff

Defend: stable but not dominant

Evade: rare explosive read

Special: earned escalation

Desired Usage Ranges
Attack total: 45–60%

Defend: 20–30%

Evade: 10–20%

Special: 5–10%

Health Targets
beginners should overuse Attack more than Defend

Power should scare through Guard pressure first

Precision should scare through payoff, not universal dominance

Fast should win through safety and tempo

Evade should stay rare but exciting

most duels should include at least one Guard Break about 60% of
the time

most duels should include at least one Special attempt about 45%
of the time

many duels should end through momentum spikes after pressure, not flat
chip

Red Flags
any action category above 45% sustained use

any subtype above 40% in non-beginner tests

one option feeling always best

visually flat fights

disconnected mini-games

players unable to explain losses

42. Telemetry and Playtesting
42.1 Core Telemetry
action pick rates

subtype pick rates

win rates by character

win rates by difficulty

mini-game grade distributions

mini-game fail rates

Guard Break count per duel

average duel length

replay skip rate

skipped exchange count

explanation-line display count

early-confirm frequency

42.2 Key Watchpoints
acceptable character win-rate gap: ≤8%

any category above 45% sustained use is a warning

any subtype above 40% in non-beginner tests suggests spam

42.3 Post-Playtest Questions
Did you understand what Attack / Defend / Evade / Special were
doing?

Did Fast / Power / Precision feel different?

Did the mini-games feel connected or pasted on?

Did one option feel always best?

Did the fight feel anime-cool?

Did you understand why you won or lost exchanges?

Was the replay exciting or too long?

Which mini-game felt best and worst?

43. Build Order Recommendation
Combat state machine

Action picker + timer

AI decision + simulated grade model

Mini-game overlays

HP / Guard / Meter resolution

Baseline playback / camera / hit stop

Character tuning split

Special system

Replay highlight reel

Tutorial / onboarding pass

44. Change Policy
Freely Adjustable During Testing
damage values

threshold values

meter values

Guard recovery values

replay pacing

camera emphasis

Must Not Drift Casually
action interaction backbone

Fast / Power / Precision identities

Guard Break / Vulnerable meaning

Special conditions

turn flow

Priority Order if Feel Conflicts With Clarity
readability

fairness

anime spectacle

Most Acceptable Simplification
Reduce replay depth first.

Least Acceptable Compromise
Do not muddy combat readability.

45. Final Locked Rules
Do not reopen these unless playtests clearly break them:

7-second planning timer

simultaneous hidden lock-in

one-round duel

100 HP / 100 Guard / 0 Meter start

2 characters

1 arena

3 mini-games

Attack / Defend / Evade / Special

Fast / Power / Precision

Guard Break creates Vulnerable for 1 exchange

Specials cost 50

keyboard-first controls

replay may simplify

combat clarity may not simplify

46. One-Page Super Summary
If a developer remembers only one page, it should be this:

Build a single-player, keyboard-first anime duel in Godot.

Two fighters secretly choose Attack / Defend / Evade / Special
every 7 seconds.

If Attack is chosen, the player picks Fast / Power / Precision.

The game resolves a baseline combat relationship first, then one
visible mini-game unless the exchange qualifies for Quick Resolve.

Mini-game mapping:

Fast → Pattern

Power → Timing

Precision → Typing

Grades are Miss / Weak / Good / Perfect.

Combat philosophy is 60% read / 40% execution.

HP, Guard, and Meter all matter.

Guard Break creates Vulnerable for 1 exchange but does not remove
defender agency.

Martial Artist = flow, safer pressure, smoother recovery.

Samurai = heavier commitment, stronger punish, higher ceiling.

Every exchange must become a short anime-style playback beat.

After the fight, play a 10–20 second highlight replay.

The game succeeds only if the raw exchange already feels like a duel
before the replay makes it cooler.

47. Final Design Truth
The game deserves to exist if a player can honestly say:

“I wasn’t just doing a mini-game. I made a read, held my nerve,
cracked their composure, and watched it become a real anime duel.”

That is the standard the vertical slice must meet.