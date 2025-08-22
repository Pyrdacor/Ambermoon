using System;
using Ambermoon.Data;
using AmbermoonEditor.Controls;
using AmbermoonEditor.Extensions;
using Attribute = Ambermoon.Data.Attribute;

namespace AmbermoonEditor;

enum CharacterValueType
{
    HpSp,
    Attribute,
    Skill
}

public partial class CharacterControl(CharacterType characterType) : DataControl
{
    private readonly CharacterStatsControl characterStatsControl = new();

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (characterType == CharacterType.PartyMember)
        {
            
        }
        else if (characterType == CharacterType.NPC)
        {
            comboBoxCharacters.DataSource = GameData.CharacterManager.NPCs;
            comboBoxCharacters.DisplayMember = "Name";
        }
        else
        {
            throw new Exception($"Invalid character type for {nameof(CharacterControl)}: {characterType}");
        }

        multiPageControl.AddPage("Stats", characterStatsControl);
    }

    private protected virtual void OnCharacterSelected(Character character)
    {

    }

    private void ComboBoxCharacters_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (comboBoxCharacters.SelectedItem is not Character character)
        {
            return;
        }

        labelRace.Text = character.Race.ToString();
        labelGender.Text = character.Gender.ToString();
        labelAge.Text = "Age: " + character.Attributes[Attribute.Age].CurrentValue.ToString();
        labelClassAndLevel.Text = $"{character.Class} {character.Level}";
        labelExp.Text = "EP: " + character.ExperiencePoints.ToString();

        labelName.Text = character.Name;

        bool magicClass = character.Class.IsMagic();

        labelHP.Text = "HP: " + character.HitPoints.FormatCharacterValue(CharacterValueType.HpSp);
        labelSP.Text = magicClass ? "SP: " + character.SpellPoints.FormatCharacterValue(CharacterValueType.HpSp) : "";
        labelSLPAndTP.Text = magicClass ? $"SLP: {character.SpellLearningPoints}, TP: {character.TrainingPoints}" : $"TP: {character.TrainingPoints}";
        labelGoldAndFood.Text = $"Gold: {character.Gold}, Food: {character.Food}";

        var dmg = character.BonusAttackDamage + character.AttributeValue(Attribute.Strength) / 25;
        var def = character.BonusDefense + character.AttributeValue(Attribute.Stamina) / 25;
        labelDmgAndDef.Text = $"Dmg: {dmg}, Def: {def}";

        characterStatsControl.Character = character;

        OnCharacterSelected(character);
    }
}
