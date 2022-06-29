using System;
using System.Collections;
using System.Collections.Generic;

namespace AmbermoonMapEditor2D
{
    class DropOutStack<T> : IEnumerable<T> where T : class
    {
        T[] items;
        int top = 0;

        public int Count { get; private set; } = 0;

        public DropOutStack(int capacity)
        {
            items = new T[capacity];
        }

        public bool Push(T item)
        {
            bool dropOut = Count == items.Length;
            items[top] = item;
            top = (top + 1) % items.Length;
            Count = Math.Min(Count + 1, items.Length);
            return dropOut;
        }

        public T Peek()
        {
            if (Count == 0)
                return null;

            int peekTop = (items.Length + top - 1) % items.Length;

            return items[peekTop];
        }

        public T Pop()
        {
            if (Count == 0)
                throw new InvalidOperationException("Pop on an empty stack");

            top = (items.Length + top - 1) % items.Length;
            var item = items[top];
            items[top] = null;
            --Count;
            return item;
        }

        public void Clear()
        {
            items = new T[items.Length];
            Count = 0;
            top = 0;
        }

        class StackEnumerator<T> : IEnumerator<T>, IEnumerator where T : class
        {
            readonly DropOutStack<T> stack;
            int position = -1;

            public StackEnumerator(DropOutStack<T> stack)
            {
                this.stack = stack;
            }

            object IEnumerator.Current => Current;

            public T Current
            {
                get
                {
                    try
                    {
                        return stack.items[position];
                    }
                    catch (IndexOutOfRangeException)
                    {
                        throw new InvalidOperationException("Stack enumerator points to invalid item.");
                    }
                }
            }

            public void Dispose()
            {

            }

            public bool MoveNext()
            {
                if (position == -1)
                {
                    int peekTop = stack.Count == 0 ? 0 : (stack.items.Length + stack.top - 1) % stack.items.Length;
                    position = peekTop;
                    return stack.Count != 0;
                }
                else
                {
                    position = (stack.items.Length + position - 1) % stack.items.Length;
                    while (stack.items[position] == null)
                    {
                        position = (stack.items.Length + position - 1) % stack.items.Length;
                    }
                    return ((position + 1) % stack.items.Length) != stack.top;
                }
            }

            public void Reset()
            {
                position = -1;
            }
        }

        public IEnumerator<T> GetEnumerator() => new StackEnumerator<T>(this);

        IEnumerator IEnumerable.GetEnumerator() => new StackEnumerator<T>(this);
    }
}
