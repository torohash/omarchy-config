# fcitx5 classicui theme "omarchy" (Soft) — rendered from colors.toml by Omarchy
# Installed by the theme-set hook fcitx5-theme into ~/.local/share/fcitx5/themes/omarchy/
[Metadata]
Name=Omarchy
Version=3
Author=local
Description=Follows the current Omarchy theme
ScaleWithDPI=True

[InputPanel]
NormalColor={{ foreground }}
HighlightCandidateColor={{ bright_foreground }}
CandidateLabelColor={{ accent }}
HighlightCandidateLabelColor={{ accent }}
CandidateCommentColor={{ dark_foreground }}
HighlightColor={{ bright_foreground }}
HighlightBackgroundColor={{ selection }}
FullWidthHighlight=True
EnableBlur=False
PageButtonAlignment=Last Candidate

[InputPanel/Background]
Image=panel.svg

[InputPanel/Background/Margin]
Left=9
Right=9
Top=9
Bottom=9

[InputPanel/Highlight]
Image=highlight.svg

[InputPanel/Highlight/Margin]
Left=6
Right=6
Top=6
Bottom=6

[InputPanel/ContentMargin]
Left=6
Right=6
Top=6
Bottom=6

[InputPanel/TextMargin]
Left=10
Right=10
Top=5
Bottom=5

[InputPanel/PrevPage]
Image=prev.svg

[InputPanel/NextPage]
Image=next.svg

[InputPanel/ShadowMargin]
Left=0
Right=0
Top=0
Bottom=0

[Menu]
NormalColor={{ foreground }}
HighlightCandidateColor={{ bright_foreground }}
Spacing=0

[Menu/Background]
Image=panel.svg

[Menu/Background/Margin]
Left=9
Right=9
Top=9
Bottom=9

[Menu/Highlight]
Image=highlight.svg

[Menu/Highlight/Margin]
Left=6
Right=6
Top=6
Bottom=6

[Menu/Separator]
Color={{ muted }}

[Menu/CheckBox]
Image=radio.svg

[Menu/SubMenu]
Image=arrow.svg

[Menu/ContentMargin]
Left=6
Right=6
Top=6
Bottom=6

[Menu/TextMargin]
Left=10
Right=10
Top=5
Bottom=5
