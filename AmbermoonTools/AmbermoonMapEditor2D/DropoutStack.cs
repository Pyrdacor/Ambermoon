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

        public IEnumerator<T> GetEnumerator() => (IEnumerator<T>)items.GetEnumerator();

        IEnumerator IEnumerable.GetEnumerator() => items.GetEnumerator();
    }
}
