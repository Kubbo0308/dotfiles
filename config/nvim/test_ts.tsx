import React, { useState } from 'react';

interface Props {
  name: string;
  age?: number;
}

const TestComponent: React.FC<Props> = ({ name, age }) => {
  const [count, setCount] = useState<number>(0);

  const handleClick = () => {
    setCount(count + 1);
  };

  return (
    <div>
      <h1>Hello, {name}!</h1>
      {age && <p>Age: {age}</p>}
      <button onClick={handleClick}>Count: {count}</button>
    </div>
  );
};

export default TestComponent;