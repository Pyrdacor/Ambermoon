using System;
using System.Collections.Generic;
using System.Linq;

namespace AmbermoonMapEditor2D
{
    class History
    {
        public interface IAction
        {
            string DisplayName { get; }
            string UndoDisplayName { get; }
            void Do();
            void Undo();
            void Redo();
        }

        public class DefaultAction: IAction
        {
            readonly Action<bool> doAction;
            readonly Action undoAction;

            public string DisplayName { get; }
            public string UndoDisplayName { get; }

            public DefaultAction(string displayName, string undoDisplayName,
                Action<bool> doAction, Action undoAction)
            {
                DisplayName = displayName;
                UndoDisplayName = undoDisplayName;
                this.doAction = doAction;
                this.undoAction = undoAction;
            }

            public void Do() => doAction?.Invoke(false);
            public void Undo() => undoAction?.Invoke();
            public void Redo() => doAction?.Invoke(true);
        }

        public bool Dirty => (savedAtAction != null && actions.Count == 0) ||
            (actions.Count != 0 && savedAtAction != actions.Peek());
        public const int HistorySize = 128;
        IAction savedAtAction = null;
        readonly DropOutStack<IAction> actions = new DropOutStack<IAction>(HistorySize);
        readonly DropOutStack<IAction> undoneActions = new DropOutStack<IAction>(HistorySize);
        public event Action UndoGotFilled;
        public event Action UndoGotEmpty;
        public event Action RedoGotFilled;
        public event Action RedoGotEmpty;

        public void DoAction(IAction action)
        {
            if (undoneActions.Count != 0)
            {
                undoneActions.Clear();
                RedoGotEmpty?.Invoke();
            }

            actions.Push(action);
            action.Do();

            if (actions.Count == 1)
                UndoGotFilled?.Invoke();
        }

        public void Undo()
        {
            if (actions.Count == 0)
                return;

            var undoAction = actions.Pop();
            undoAction.Undo();
            undoneActions.Push(undoAction);

            if (actions.Count == 0)
                UndoGotEmpty?.Invoke();
            if (undoneActions.Count == 1)
                RedoGotFilled?.Invoke();
        }

        public void Redo()
        {
            var action = undoneActions.Pop();
            actions.Push(action);
            action.Redo();

            if (actions.Count == 1)
                UndoGotFilled?.Invoke();
            if (undoneActions.Count == 0)
                RedoGotEmpty?.Invoke();
        }

        public void Clear()
        {
            actions.Clear();
            savedAtAction = null;
        }

        public void Save() => savedAtAction = actions.Peek();

        public string[] GetUndoNames()
        {
            return actions.Select(action => action.DisplayName).ToArray();
        }

        public string[] GetRedoNames()
        {
            return undoneActions.Select(action => action.UndoDisplayName).ToArray();
        }
    }
}
