using System.ComponentModel;
using System.Windows.Forms;
using Ambermoon.Data;
using AmbermoonEditor.Extensions;
using Attribute = Ambermoon.Data.Attribute;

namespace AmbermoonEditor.Controls;

public partial class CharacterStatsControl : UserControl
{
    private Character character;

    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    internal Character Character
    {
        get => character;
        set
        {
            if (character == value)
                return;

            character = value;

            OnCharacterChanged();
        }
    }

    public CharacterStatsControl()
    {
        InitializeComponent();
    }

    private void OnCharacterChanged()
    {
        // Attributes
        labelStrength.Text = "Str: " + character.Attributes[Attribute.Strength].FormatCharacterValue(CharacterValueType.Attribute);
        labelIntelligence.Text = "Int: " + character.Attributes[Attribute.Intelligence].FormatCharacterValue(CharacterValueType.Attribute);
        labelDexterity.Text = "Dex: " + character.Attributes[Attribute.Dexterity].FormatCharacterValue(CharacterValueType.Attribute);
        labelSpeed.Text = "Spd: " + character.Attributes[Attribute.Speed].FormatCharacterValue(CharacterValueType.Attribute);
        labelStamina.Text = "Sta: " + character.Attributes[Attribute.Stamina].FormatCharacterValue(CharacterValueType.Attribute);
        labelCharisma.Text = "Cha: " + character.Attributes[Attribute.Charisma].FormatCharacterValue(CharacterValueType.Attribute);
        labelLuck.Text = "Luk: " + character.Attributes[Attribute.Luck].FormatCharacterValue(CharacterValueType.Attribute);
        labelAntiMagic.Text = "A-M: " + character.Attributes[Attribute.AntiMagic].FormatCharacterValue(CharacterValueType.Attribute);

        // Skills
        labelAttack.Text = "Atk: " + character.Skills[Skill.Attack].FormatCharacterValue(CharacterValueType.Skill);
        labelParry.Text = "Par: " + character.Skills[Skill.Parry].FormatCharacterValue(CharacterValueType.Skill);
        labelSwim.Text = "Swi: " + character.Skills[Skill.Swim].FormatCharacterValue(CharacterValueType.Skill);
        labelCrit.Text = "Cri: " + character.Skills[Skill.CriticalHit].FormatCharacterValue(CharacterValueType.Skill);
        labelFindTraps.Text = "F-T: " + character.Skills[Skill.FindTraps].FormatCharacterValue(CharacterValueType.Skill);
        labelDisarmTraps.Text = "D-T: " + character.Skills[Skill.DisarmTraps].FormatCharacterValue(CharacterValueType.Skill);
        labelLockpick.Text = "L-P: " + character.Skills[Skill.LockPicking].FormatCharacterValue(CharacterValueType.Skill);
        labelSearch.Text = "Sea: " + character.Skills[Skill.Searching].FormatCharacterValue(CharacterValueType.Skill);
        labelReadMagic.Text = "R-M: " + character.Skills[Skill.ReadMagic].FormatCharacterValue(CharacterValueType.Skill);
        labelUseMagic.Text = "U-M: " + character.Skills[Skill.UseMagic].FormatCharacterValue(CharacterValueType.Skill);
    }
}
