import React from 'react';
import { shallow } from 'enzyme';
import Slideshow from 'packs/postgame/Slideshow';
import { finished } from 'stream';
var mock_games_index_request = require('../mock_games_index_request')

describe('Slideshow component', () => {
  describe('smoke test', () => {
    it('a carousel is on the screen', () => {
      const props = mock_games_index_request.arr_of_postgame_card_set[0];
      
      const postgame = shallow(<Slideshow deck={props} />);
      // expect( postgame.contains('.card-header .nav-item') ).to.have.lengthOf(2);
      // expect( postgame.contains('.card-header .nav-item:eq(1)') ).to.eq.lengthOf(2);
      // expect( postgame.children(CarouselItem) ).to.have.lengthOf(props.length);
    });
  });

  // describe('while on the page', ()=>{
  //   describe('selects a different game in the dropdown selector', ()=>{
  //     fit("", ()=>{
  //       const carousel_item = shallow(CarouselItem)
  //     });
  //   });

  //   describe('selects the same game in the dropdown selector', ()=>{
  //     it("doesn't get other ", ()=>{
  //       expect(1).toEqual(1);

  //     });
  //   });
  // });
});


