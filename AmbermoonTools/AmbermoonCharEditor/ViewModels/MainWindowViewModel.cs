using Ambermoon.Data;
using AmbermoonCharEditor.Views;
using AutoMapper;

namespace AmbermoonCharEditor.ViewModels
{
    public class MainWindowViewModel : ViewModelBase
    {
        readonly MainWindow window;
        static readonly IMapper partyMemberToNPCMapper;
        static readonly IMapper partyMemberToMonsterMapper;
        static readonly IMapper npcToPartyMemberMapper;
        static readonly IMapper npcToMonsterMapper;
        static readonly IMapper monsterToPartyMemberMapper;
        static readonly IMapper monsterToNPCMapper;

        static MainWindowViewModel()
        {
            var config = new MapperConfiguration(cfg => cfg.CreateMap<PartyMember, NPC>());
            partyMemberToNPCMapper = config.CreateMapper();
            config = new MapperConfiguration(cfg => cfg.CreateMap<PartyMember, Monster>());
            partyMemberToMonsterMapper = config.CreateMapper();
            config = new MapperConfiguration(cfg => cfg.CreateMap<NPC, PartyMember>());
            npcToPartyMemberMapper = config.CreateMapper();
            config = new MapperConfiguration(cfg => cfg.CreateMap<NPC, Monster>());
            npcToMonsterMapper = config.CreateMapper();
            config = new MapperConfiguration(cfg => cfg.CreateMap<Monster, PartyMember>());
            monsterToPartyMemberMapper = config.CreateMapper();
            config = new MapperConfiguration(cfg => cfg.CreateMap<Monster, NPC>());
            monsterToNPCMapper = config.CreateMapper();
        }

        static Character CreateDefaultCharacter()
        {
            return new Monster
            {
                Name = "Unnamed"
            };
        }

        public MainWindowViewModel(MainWindow window)
        {
            this.window = window;
        }

        public Character Character { get; private set; } = CreateDefaultCharacter();
        CharacterType? characterType = CharacterType.Monster;
        public bool PartyMember
        {
            get => characterType == CharacterType.PartyMember;
            set
            {
                if (value)
                    SetCharacterType(CharacterType.PartyMember);
                else
                    characterType = null;
            }
        }
        public bool NPC
        {
            get => characterType == CharacterType.NPC;
            set
            {
                if (value)
                    SetCharacterType(CharacterType.NPC);
                else
                    characterType = null;
            }
        }
        public bool Monster
        {
            get => characterType == CharacterType.Monster;
            set
            {
                if (value)
                    SetCharacterType(CharacterType.Monster);
                else
                    characterType = null;
            }
        }

        void SetCharacterType(CharacterType characterType)
        {
            if (Character.Type == characterType)
                return;

            switch (characterType)
            {
                case CharacterType.PartyMember:
                    CreatePartyMember();
                    break;
                case CharacterType.NPC:
                    CreateNPC();
                    break;
                default:
                    CreateMonster();
                    break;
            }

            this.characterType = Character.Type;
        }

        void CreatePartyMember()
        {
            if (Character is NPC)
                Character = npcToPartyMemberMapper.Map<PartyMember>(Character);
            else
                Character = monsterToPartyMemberMapper.Map<PartyMember>(Character);
        }

        void CreateNPC()
        {
            if (Character is PartyMember)
                Character = partyMemberToNPCMapper.Map<NPC>(Character);
            else
                Character = monsterToNPCMapper.Map<NPC>(Character);
        }

        void CreateMonster()
        {
            if (Character is PartyMember)
                Character = partyMemberToMonsterMapper.Map<Monster>(Character);
            else
                Character = npcToMonsterMapper.Map<Monster>(Character);
        }

        public void New()
        {
            Character = CreateDefaultCharacter();
        }

        public void Open()
        {
            // TODO
        }

        public void Save()
        {
            // TODO
        }

        public void SaveAs()
        {
            // TODO
        }

        public void Exit()
        {
            window.Close();
        }
    }
}
