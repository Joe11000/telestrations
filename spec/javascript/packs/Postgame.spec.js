import React from 'react';
// import ReactDOM from 'react-dom';
import { shallow } from 'enzyme';
import Postgame from 'packs/postgame/Postgame';
import mock_games_show_request from '../mock_games_show_request';

describe('Postgame component', () => {
  describe('renders with', ()=>{
    it('a postgametab with last game displayed', ()=>{
      const postgame = render(<Postgame mock_games_show_request/>)
      const postgame_shallow = shallow(<Postgame mock_games_show_request/>)
      debugger
      expect(postgame.find(CarouselItem)).toEqual()
      expect( postgame.contains('.card') ).toBeDefined();

    });

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
