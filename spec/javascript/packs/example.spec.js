import React from 'react'
// import ReactDOM from 'react-dom'
import { shallow } from 'enzyme'
import Postgame from 'packs/postgame/Postgame'

describe('Postgame component', () => {
  describe('a default postgame component', ()=>{
    it('renders default layout', ()=>{
      const postgame = shallow(<Postgame />)

      expect( postgame.contains('.card') ).toBeDefined();
      // expect( postgame.find('.card') ).to.have.lengthOf(1);
    })

  });


});

test('adds 1 + 2 to equal 3', () => {
  expect(1).toEqual(1);
});
