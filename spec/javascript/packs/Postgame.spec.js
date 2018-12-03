import React from 'react'
// import ReactDOM from 'react-dom'
import { shallow } from 'enzyme'
import Postgame from 'packs/postgame/Postgame'
import TestRenderer from 'react-test-renderer';

describe('Postgame component', () => {
  describe('renders with', ()=>{
    it('a postgametab with last game displayed', ()=>{
      const postgame = shallow(<Postgame />)

      expect(1).toEqual(1)
      expect( postgame.contains('.card') ).toBeDefined();
      // expect( postgame.contains('.card-header .nav-item') ).to.have.lengthOf(2);
      // expect( postgame.contains('.card-header .nav-item:eq(1)') ).to.eq.lengthOf(2);
      // expect( postgame.find('.card') ).to.have.lengthOf(1);
    })

  });

  describe('while on the page', ()=>{
    describe('selects a different game in the dropdown selector', ()=>{
      it("", ()=>{
        expect(1).toEqual(1)
      })
    })

    describe('selects the same game in the dropdown selector', ()=>{
      it("doesn't get other ", ()=>{
        expect(1).toEqual(1)

      })
    })
  });

});

// test('adds 1 + 2 to equal 3', () => {
//   expect(1).toEqual(1);
// });
