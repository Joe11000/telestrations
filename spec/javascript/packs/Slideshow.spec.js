import React from 'react';
import { shallow } from 'enzyme';
// import TestRenderer from 'react-test-renderer';
import Slideshow from 'packs/postgame/Slideshow';
var mock_games_index_request = require('../mock_games_index_request')

describe('Slideshow component', () => {
  describe('smoke test', () => {
    it('a carousel is on the screen', () => {
      const props = mock_games_index_request[0];
      
      debugger;
      const postgame = shallow(<Slideshow {...props} />)
      // expect( postgame.contains('.card-header .nav-item') ).to.have.lengthOf(2);
      // expect( postgame.contains('.card-header .nav-item:eq(1)') ).to.eq.lengthOf(2);
      expect( postgame.children(CarouselItem) ).to.have.lengthOf(props.length);
    });
  });

  describe('while on the page', ()=>{
    describe('selects a different game in the dropdown selector', ()=>{
      it("", ()=>{
        expect(1).toEqual(1);
      });
    });

    describe('selects the same game in the dropdown selector', ()=>{
      it("doesn't get other ", ()=>{
        expect(1).toEqual(1);

      });
    });
  });

});

// test('adds 1 + 2 to equal 3', () => {
//   expect(1).toEqual(1);
// });
