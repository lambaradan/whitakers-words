---
layout: default
title: English to Latin
---

[Operational Description](operational.html) |
[Programme Description](programme.html) |
[Dictionary](dictionary.html) |
[Inflections](inflections.html) |
[English to Latin](english_to_latin.html) |
[User modifications](user_modifications.html)

# English to Latin


A fairly new application for the WORDS dictionary has been an attempt to
go English to Latin.
Up to now there is no satisfactory computer facility for this.
The best on the net is a search of the Perseus dictionary,
finding all uses of the English word in the text of the dictionary.
One can do the same with the WORDS dictionary,
and `DICTPAGE.TXT` is a convenient form for that purpose.
In the present release of WORDS, a primitive English-to-Latin
facility has been implemented, based on this inverted dictionary method.

However, except for very simple situations,
the resulting raw output can be excessive and often spurious.
It is necessary to TRIM the output for the general user.
In order to do this, one needs to be able to computer parse the MEAN field
and prioritize the significance of a word appearing therein.
This is a more rigorous requirement than the one applied hitheretofore,
that MEAN should be human-readable.  Now it must be computer parsed.
Therein lies the reason for a formal set of rules for constructing MEAN.
These rules are new and certainly have not been applied throughout
the dictionary yet, further,
they may change in the future if more powerful ordering algorithms evolve.

The primary rule is that nothing should surprise or
inconvenience the casual user of WORDS.
Further, for system independence,
the MEAN line should be readable by anyone in ASCII,
without special characters or fonts.


I have just begun to work on an English-to-Latin capability.
Initially this is just a inversion of the WORDS Latin dictionary,
extracting all the English words in the MEAN field of the WORDS dictionary
and associating these with the corresponding Latin entry.
A real English-to-Latin is much more than that.
To construct from first principles,
one should take a set of English words and find the Latin equivalent,
not the reverse.
Nevertheless, WORDS now has some primitive capability.

The raw inversion produces almost 200_000 English words.
WEEDing them by the present algorithms (eliminate a, the, to, ...,
and a number of common modifiers when included in meanings not of
their part of speech)
reduces this number only by a third.
But this finally results in only somewhat over 20_000 unique words,
less than the number of Latin entries!
This probably reflects more on dictionary makers than on the languages.


English is certainly a far richer language than Latin, measured
by the number of individual words.
WORDS has about 40_000 Latin entries, and the corresponding inversion to
English yields only 22_000 unique English words.


The reason seems to be that,
while English may have lots of words for love or hate,
in making up a Latin
dictionary one will opt to give a simple translation.
So while love is a proper translation of a number of Latin words,
and one could as well replace it with any of dozens of English synonyms,
a dictionary compiler will usually take the simplest English word
that provides the reader with the meaning.   That is what the reader usually wants.


Starting from an English basis to produce an English-to-Latin dictionary
gives an entirely different outcome.
In that case, the full power of English can be invoked,
and it is the Latin that will seem simple by comparison.

In many cases, an English-to-Latin dictionary bound in the same volume
as a Latin-to-English will have been
developed by a different author, and sometimes they are not consistent.
At least the inversion procedure assures basic consistency.

One problem with the inversion method is that one needs
to weed out a lot of the chaff before presenting to the user.
And even then there are a lot of choices for the user.
GOLD occurs 120 times; COPPER, 57 times: ABANDON, 24 times,
plus several times for ABANDONED, ABANDONS, ABANDONING, and ABANDONMENT.
Further trimming has to get very severe!



If the program is run with TRIM_OUTPUT parameter set
(this parameter works on both Latin and English output),
the six highest priority (by FREQ or whatever the current algorithm is)
will be listed.  This should serve for the general user.
Turning off this parameter allows the program to list all instances
found in the Latin dictionary,
which were not removed by WEEDing in the data preparation.

Finally there is the problem that most paper Latin dictionaries harken back
to the 19th century or earlier, even those published more recently.
Their base English may not be current.
Take a purely hypothetical example.  On the first page of every English-Latin
dictionary is *abase*.  This is a good 18th century word.  Today one is
more likely to see humble, degrade or humiliate, and those are the words the
user is more likely to request.  But the dictionaries from which WORDS draws
may be fonder of abase as the meaning of a Latin word which could serve for
any of these.  The user may want to try some synonyms, but this can be
a considerable burden.  A built-in thesaurus could mechanically generate
a broad range of words to include, but this is surely overkill and will
generate so many inappropriate results as to render the search excessively
cumbersome.  The user is advised to check the meanings returned for suggestions
as to what other words might be tried, if the immediate result does not
seem satisfactory.


One important point is that the program mechanically searches the Latin dictionary.
If one is looking for a adjective, presently one will find all adjectives for which the
MEAN contains the search word, no more.  However one should be aware that
participles of appropriate verbs can also serve as adjectives and may be
a better choice.

At the present time there is no complex construction/deconstruction
of the English input.  Thus if the input is 'kill', only Latin entries
with the exact word 'kill' in their MEAN will be selected.  The suffixed words
'kills'/'killing'/'killed'/'killer'/etc. will not be found.  They must
be queried separately.
Likewise, unlike the Latin phase of WORDS, prefixes are not extracted.
It may be desirable in the future to provide such additional capabilities.
This would be value added over simple search by the program.


## English Parsing of Meanings


Punctuation in meanings is now formalized, in order
to allow computer processing of the text.
Deviation from these rules would make parsing
of the English very difficult, so they must be enforced.
There is nothing which will mislead the user,
but it goes beyond standard text practice.


The semicolon separator has greater significance.
Various groups of meanings may have varying frequency or likelihood.
The most likely are placed first and thereby prioritized.
Within a semicolon group (SEMI) of meaning/synonyms separated by commas or slashes,
their probability is assumed to be the same.
Where possible, a PURE word (e.g., 'perhaps') should lead,
followed by compound meanings (e.g., 'it may be').
There is much work to do before this ordering is complete.

Any PURE meaning (one not involving modifiers) set off by
commas or slashes, is assigned a high priority on output that
a modified/compound meaning in the same MEAN SEMI.

Semicolons separate meaning groups that have a different
flavor/sense.
Initially the interpretation and selection among these were left
to the user, as in paper dictionaries.
Recent requirements demand an ordering of these groups.
The order of the semicolon groups (called SEMIs in the code) should
indicate the frequency or probability of that meaning
among different groups, where this inference can be made.
This ideal is not yet rigorously enforced, even in recent entries,
and less so in those earlier in the update.

Commas separate meanings that are roughly equivalent -
synonyms. In parsing, a COMMA consists of the words between commas.
There is no inherent logical order within a SEMI, however,
to support another application for the dictionary,
full sentence Latin-to-English translation,
it is desirable to be able to pick a single,
simple, modern English word that is most likely to be the translation.
This should be the first word of the meaning.

Question marks and exclamation points may appear as
an integral part of the meaning.  They do not replace
the comma/semicolon separator, as in normal text.

The solidus/slash (/) does the work of 'or' in many cases.
It is used solely to conserve space,
to compress the meaning line to no more than 80 characters.
It separates (generally close) synonyms and
also alternative options (jump up/out = jump up; jump out).

Plus (+) is used in the dictionary, as well as in this documentation,
in place of ampersand, for compatibility with HTML.
It s a full separator, between two words, each recognized separately.

Hyphen (-) should be is used in the dictionary only to break
into two words in the parse, each recognized separately.
Thus, book-keeper will appear in the English phrase as two words.
But it is likely that a user looking for an accountant would search
for bookkeeper, rather than book or keeper.
The dictionary has not yet been scrubbed for this situation.

Parentheses set off both possible supporting words
(go (down) = go; go down) and explanatory information.
Since parenthesized words are excluded from the extraction process,
they are a way to further reduce clutter in the English dictionary.
Words in the meaning that should not find this entry when searched
can be excluded from the English dictionary tables by parenthesizing.
(NOTE: two sets of parentheses not separated by a comma or semicolon
can cause processing troubles and should be avoided.)

Square brackets enclose translation examples or idioms,
a Latin expression to English equivalent.
The English translation of the Latin is introduced by =>.
The parser expects this (=>) token.
A bracketed expression is always
at the end of the meanings line so that it may be
extracted before spellchecking, otherwise the spellcheck
will fail on the Latin and there are an inconveniently large
number of these examples.
Brackets should never be use where parentheses are appropriate.

Generally, articles (a, an, the) are omitted in meanings.
While this compresses the line, it also reflects the fact
that Latin does not distinguish between those uses.
To define agricola as 'a' farmer would disparage the possibility
of the proper translation being 'the' farmer.  Most dictionaries
report nouns without an article.  This one go further and
avoids the use of articles almost everywhere.

Some dictionaries prefix verb meanings with TO.
This is superfluous, except in the case of a list of meanings
not distinguished by part of speech (to cut, a cut), not
the situation for this dictionary.

Vertical bars at the beginning indicate continuation meaning lines.
There may be several continuation lines,
numbered/ordered by the number of leading vertical bars.
For words with a large number of meanings,
additional meaning lines are provided by another entry for the same stems
and part with what amounts to a continuation line for MEAN.
In order to associate the resulting series of meaning lines,
a vertical bar (|)is placed at the beginning of the
first continuation MEAN, two bars for the second, etc.
The dictionary is sorted so as to assure that
these entries are grouped and ordered.
This allows checking  of the dictionary for spurious duplicate entries
without flagging intended continuation entries.
Further it facilitates compression
of the WORDS output by combining the inflection output for the several
identical parts followed by the group of meaning lines.
The STEMS and PART are identical for the base (no |) and all extensions.
They are all the same word, however they may have different flags,
that is, there may be different meanings for different AGE or AREA.

The bar is a code for MEAN continuation seen only in the raw DICTLINE.
Bars are removed before WORDS output and are not visible to the user.
There are also some entries with identical STEMS and PART which are
really different words,
different derivation and completely different meanings.
These will not be | coded and will be reported separately in output.
{NOTE: The vertical bar should not appear anywhere in meanings except
at the beginning as a continuation flag.)

Correct use of symbols/codes in MEAN is very important.
One must not use them 'free form'.
They are used in the parsing of MEAN and improper use can defeat a processing program.
While some main programs have many built-in checks,
there are a number of secondary tools which are not so 'fool proof'.
MAKEEWDS is a complicated program which I did not do well.
If it hits something strange it might well fail to properly
parse that MEAN.  The program will still complete and the
output will only lose a part of the strange MEAN, affecting only the English mode,
and may or may not not give a report on the failure.


## Ordering English-to-Latin Output

Essentially we start by associating English words in the dictionary entry meaning
with the entry number (line number in DICTLINE).
The list of English words (EWDSLIST) is sorted so that all occurrences of a particular word are together.
Then, upon inquiry, a list of the associated Latin dictionary entries is output.
Unfortunately this list could be large (a hundred or more for some common words) and thereby user-unfriendly.
The task is to order the list and reduce the output to a few most likely


Priorities for display are based on frequencies.  Besides the basic
FREQ assigned to the entry, it is presumed that the frequency is
greater for those meanings in the first SEMIs, with gradually
decreasing frequency assigned to later SEMIs and to bar flagged continuations.
The algorithm presently used is summarized below,
but it is subject to modification in future versions.






Each English word found is given a numerical RANK/priority/weight based on the algorithm below.
The numerical values of each consideration are added or subtracted to give the priority of the entry.



## FREQ

The obvious choice for frequency weights might be the comparative paper dictionary citations,
which would be roughly:


    A=>50
    B=>25
    C=>10
    D=> 5
    E=> 3
    F=> 1



However these would weight the A frequency so heavily
that it would be impossible to overcome with anything
that could be applied to lower frequencies.  So we must reject this scale
for a more manageable set:


    A=>70
    B=>60
    C=>50
    D=>40
    E=>30
    F=>20
    etc.



(N is special case, add 25 after formula)

### Compounds

Compound words ('very tall' vs. 'tall') are often useful,
indeed the user may be looking for components to make up a compound translation,
however generally they should be disparaged relative to the pure/simple word.
A compound A FREQ might be no better than a pure D.
<BR>
<BR>
Compound Yes=> 0<BR>
Compound No (Pure) =>  10<BR>
<BR>

Which SEMI (a SEMI is a part of MEAN set off by semicolons)<BR>
<BR>

-3 per SEMI  after 1

Further, a word on a continuation line is disparaged by 3 SEMIs (-9).


The words in the first SEMI are enhanced in the expectation that they are
the primary meaning.  This follows the tenuous idea that there is a single simple
translation for each English word.  At least the first SEMI is emphasized. <BR>
<BR>

If PURE and 1st SEMI => 5<BR>

Priority = FREQ value + Compound value + SEMI value + Continuation value + First SEMI value <BR>
<BR>


Example: for lamp - lanum N 3 2 N


    FREQ A => 70
    Compound No => 10
    Semi 2 => -3
    Continuation Line No => 0
    Pure 1st No => 0
    RANK/priority => 77